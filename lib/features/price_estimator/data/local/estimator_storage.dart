import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/features/price_estimator/domain/entities/nlp_scores.dart';
import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';
import 'package:vittalo/features/price_estimator/domain/entities/category_extras.dart';
import 'package:vittalo/features/price_estimator/domain/entities/product_input.dart';

// ─── Estimator Storage ────────────────────────────────────────────────────────
// Uses SharedPreferences for lightweight persistence of recent results.
// Hive can replace this for typed, high-volume storage if needed.

class EstimatorStorage {
  EstimatorStorage._();
  static final EstimatorStorage instance = EstimatorStorage._();

  static const String _historyKey = AppConstants.estimationHistoryBox;
  static const int _maxHistorySize = 20;

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> save(PriceResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await _loadRaw(prefs);
    history.insert(0, _encode(result));
    if (history.length > _maxHistorySize) history.removeLast();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // ─── Read ──────────────────────────────────────────────────────────────────

  Future<List<PriceResult>> getHistory({int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = await _loadRaw(prefs);
    return raw
        .take(limit)
        .map((e) => _decode(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Future<List<dynamic>> _loadRaw(SharedPreferences prefs) async {
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _encode(PriceResult r) => {
        'minPrice': r.minPrice,
        'maxPrice': r.maxPrice,
        'suggestedPrice': r.suggestedPrice,
        'confidenceScore': r.confidenceScore,
        'estimatedAt': r.estimatedAt.toIso8601String(),
        'nlp': {
          'urgency': r.nlpScores.urgencyScore,
          'condition': r.nlpScores.conditionScore,
          'confidence': r.nlpScores.confidence,
        },
        'input': {
          'category': r.input.category.encoded,
          'originalPrice': r.input.originalPrice,
          'purchaseDate': r.input.purchaseDate.toIso8601String(),
          'brand': r.input.brand,
          'model': r.input.model,
          'conditionPercent': r.input.conditionPercent,
          'hasPhysicalDamage': r.input.hasPhysicalDamage,
          'hasFunctionalIssues': r.input.hasFunctionalIssues,
          'accessoriesIncluded': r.input.accessoriesIncluded,
          'currentMarketPrice': r.input.currentMarketPrice,
          'reasonForSelling': r.input.reasonForSelling,
          'conditionDescription': r.input.conditionDescription,
          'imagePath': r.input.imagePath,
          'extras': r.input.extras.toJson(),
        },
      };

  PriceResult _decode(Map<String, dynamic> m) {
    final nlpMap = m['nlp'] as Map<String, dynamic>;
    final inputMap = m['input'] as Map<String, dynamic>;

    // Resolve category from encoded int
    final categoryEncoded = inputMap['category'] as int;
    final category = ProductCategory.values.firstWhere(
      (c) => c.encoded == categoryEncoded,
      orElse: () => ProductCategory.mobile,
    );

    final input = ProductInput(
      category: category,
      originalPrice: (inputMap['originalPrice'] as num).toDouble(),
      purchaseDate: DateTime.parse(inputMap['purchaseDate'] as String),
      brand: inputMap['brand'] as String,
      model: inputMap['model'] as String,
      conditionPercent: (inputMap['conditionPercent'] as num).toDouble(),
      hasPhysicalDamage: inputMap['hasPhysicalDamage'] as bool,
      hasFunctionalIssues: inputMap['hasFunctionalIssues'] as bool,
      accessoriesIncluded: inputMap['accessoriesIncluded'] as bool,
      currentMarketPrice: inputMap['currentMarketPrice'] != null
          ? (inputMap['currentMarketPrice'] as num).toDouble()
          : null,
      reasonForSelling: inputMap['reasonForSelling'] as String,
      conditionDescription: inputMap['conditionDescription'] as String,
      imagePath: inputMap['imagePath'] as String?,
      extras: inputMap['extras'] != null
          ? CategoryExtras.fromJson(
              Map<String, dynamic>.from(inputMap['extras'] as Map))
          : CategoryExtras.empty,
    );

    return PriceResult(
      minPrice: (m['minPrice'] as num).toDouble(),
      maxPrice: (m['maxPrice'] as num).toDouble(),
      suggestedPrice: (m['suggestedPrice'] as num).toDouble(),
      confidenceScore: (m['confidenceScore'] as num).toDouble(),
      estimatedAt: DateTime.parse(m['estimatedAt'] as String),
      nlpScores: NlpScores(
        urgencyScore: (nlpMap['urgency'] as num).toDouble(),
        conditionScore: (nlpMap['condition'] as num).toDouble(),
        confidence: (nlpMap['confidence'] as num).toDouble(),
      ),
      input: input,
    );
  }
}
