import 'dart:convert';

import 'package:flutter/services.dart';

class LivestockStageIdentificationRules {
  LivestockStageIdentificationRules._({
    required this.genericYoungStages,
    required List<_LivestockStageRule> rules,
  }) : _rules = rules;

  static const assetPath =
      'assets/data/livestock_stage_identification_rules.json';

  static final fallback = LivestockStageIdentificationRules._(
    genericYoungStages: const {
      'newborn',
      'neonate',
      'suckling',
      'unweaned',
      'weaner',
      'juvenile',
      'piglet',
      'calf',
      'kid',
      'lamb',
      'chick',
      'puppy',
      'kitten',
      'foal',
      'duckling',
    },
    rules: const [],
  );

  final Set<String> genericYoungStages;
  final List<_LivestockStageRule> _rules;

  static Future<LivestockStageIdentificationRules> load() async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final generic = _stringSet(json['genericYoungStages']);
      final rules = (json['livestockTypes'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_LivestockStageRule.fromJson)
          .toList(growable: false);
      return LivestockStageIdentificationRules._(
        genericYoungStages: generic,
        rules: rules,
      );
    } catch (_) {
      return fallback;
    }
  }

  bool isYoungStage({required String livestockType, required String stage}) {
    final normalizedStage = _normalize(stage);
    if (normalizedStage.isEmpty) return false;
    final normalizedType = _normalize(livestockType);
    for (final rule in _rules) {
      if (!rule.aliases.contains(normalizedType)) continue;
      if (rule.youngStages.contains(normalizedStage)) return true;
      if (rule.matureStages.contains(normalizedStage)) return false;
      break;
    }
    return genericYoungStages.contains(normalizedStage);
  }

  static Set<String> _stringSet(dynamic value) =>
      (value as List<dynamic>? ?? const [])
          .map((item) => _normalize(item.toString()))
          .where((item) => item.isNotEmpty)
          .toSet();

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

class _LivestockStageRule {
  const _LivestockStageRule({
    required this.aliases,
    required this.youngStages,
    required this.matureStages,
  });

  factory _LivestockStageRule.fromJson(Map<String, dynamic> json) =>
      _LivestockStageRule(
        aliases: LivestockStageIdentificationRules._stringSet(json['aliases']),
        youngStages: LivestockStageIdentificationRules._stringSet(
          json['youngStages'],
        ),
        matureStages: LivestockStageIdentificationRules._stringSet(
          json['matureStages'],
        ),
      );

  final Set<String> aliases;
  final Set<String> youngStages;
  final Set<String> matureStages;
}
