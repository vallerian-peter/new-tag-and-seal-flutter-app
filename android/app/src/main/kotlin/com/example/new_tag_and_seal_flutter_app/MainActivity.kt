package com.example.new_tag_and_seal_flutter_app

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "reports/downloads",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requiresLegacyStoragePermission" -> {
                    result.success(Build.VERSION.SDK_INT < Build.VERSION_CODES.Q)
                }
                "savePdfToDownloads" -> {
                    val args = call.arguments as? Map<*, *>
                    val fileName = args?.get("fileName") as? String
                    val bytes = args?.get("bytes") as? ByteArray

                    if (fileName.isNullOrBlank() || bytes == null) {
                        result.error(
                            "invalid_arguments",
                            "fileName and bytes are required",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    runCatching {
                        savePdfToDownloads(fileName, bytes)
                    }.onSuccess { savedPath ->
                        result.success(savedPath)
                    }.onFailure { error ->
                        result.error(
                            "save_failed",
                            error.message,
                            null,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun savePdfToDownloads(fileName: String, bytes: ByteArray): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = applicationContext.contentResolver
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS,
                )
            }

            val uri = resolver.insert(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                contentValues,
            ) ?: error("Unable to create Downloads entry")

            resolver.openOutputStream(uri)?.use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            } ?: error("Unable to open Downloads output stream")

            "Downloads/$fileName"
        } else {
            val permission = ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
            )
            if (permission != PackageManager.PERMISSION_GRANTED) {
                error("Storage permission is required to save reports")
            }

            val downloadsDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS,
            )
            if (!downloadsDir.exists()) {
                downloadsDir.mkdirs()
            }

            val outputFile = File(downloadsDir, fileName)
            FileOutputStream(outputFile).use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            }

            MediaScannerConnection.scanFile(
                this,
                arrayOf(outputFile.absolutePath),
                arrayOf("application/pdf"),
                null,
            )

            outputFile.absolutePath
        }
    }
}
