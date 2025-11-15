import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Utility helpers for managing alarm audio assets.
class AlarmAudioUtils {
  static const String soundsFolder = 'alarm_sounds';
  static const String defaultFileName = 'default_alarm.wav';

  /// Ensures that the bundled default alarm sound exists on disk.
  ///
  /// Returns the relative path (from the application documents directory)
  /// that can be used with the `alarm` plugin.
  static Future<String> ensureDefaultAlarmSound() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(docsDir.path, soundsFolder));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final file = File(p.join(folder.path, defaultFileName));
    if (!await file.exists()) {
      final bytes = _generateSineWaveWav(
        duration: const Duration(seconds: 5),
        frequencyHz: 660,
      );
      await file.writeAsBytes(bytes, flush: true);
    }

    return p.join(soundsFolder, defaultFileName);
  }

  /// Copies a picked audio file into the app sounds directory and returns
  /// the relative path.
  static Future<String> copySoundToAppDirectory(String sourcePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(docsDir.path, soundsFolder));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourcePath)}';
    final targetPath = p.join(folder.path, fileName);
    await File(sourcePath).copy(targetPath);

    return p.relative(targetPath, from: docsDir.path);
  }

  /// Resolves an absolute file system path from a relative [soundPath].
  static Future<String> resolveAbsolutePath(String soundPath) async {
    if (p.isAbsolute(soundPath)) return soundPath;
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, soundPath);
  }

  static Uint8List _generateSineWaveWav({
    required Duration duration,
    required double frequencyHz,
    int sampleRate = 44100,
  }) {
    final totalSamples = duration.inMilliseconds * sampleRate ~/ 1000;
    final bytes = BytesBuilder();

    // WAV header
    final header = _buildWavHeader(
      sampleRate: sampleRate,
      channels: 1,
      bitsPerSample: 16,
      dataLength: totalSamples * 2,
    );
    bytes.add(header);

    final amplitude = 0.6;
    for (int i = 0; i < totalSamples; i++) {
      final time = i / sampleRate;
      final value = sin(2 * pi * frequencyHz * time);
      final sample = (value * amplitude * 0x7FFF).round();
      bytes.add(_int16ToBytes(sample));
    }
    return bytes.toBytes();
  }

  static Uint8List _buildWavHeader({
    required int sampleRate,
    required int channels,
    required int bitsPerSample,
    required int dataLength,
  }) {
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final buffer = BytesBuilder();

    void writeString(String value) {
      buffer.add(value.codeUnits);
    }

    void writeInt32(int value) {
      buffer.add([
        value & 0xFF,
        (value >> 8) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 24) & 0xFF,
      ]);
    }

    void writeInt16(int value) {
      buffer.add([
        value & 0xFF,
        (value >> 8) & 0xFF,
      ]);
    }

    writeString('RIFF');
    writeInt32(36 + dataLength);
    writeString('WAVE');
    writeString('fmt ');
    writeInt32(16); // PCM chunk size
    writeInt16(1); // PCM format
    writeInt16(channels);
    writeInt32(sampleRate);
    writeInt32(byteRate);
    writeInt16(blockAlign);
    writeInt16(bitsPerSample);
    writeString('data');
    writeInt32(dataLength);

    return buffer.toBytes();
  }

  static Uint8List _int16ToBytes(int value) {
    final clamped = value & 0xFFFF;
    return Uint8List(2)
      ..[0] = clamped & 0xFF
      ..[1] = (clamped >> 8) & 0xFF;
  }
}

