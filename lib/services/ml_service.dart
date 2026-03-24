import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/features/price_estimator/domain/entities/nlp_scores.dart';
import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';
import 'package:vittalo/features/price_estimator/domain/entities/product_input.dart';

// ─── ML Service ───────────────────────────────────────────────────────────────
// Stores raw model bytes so the Interpreter can be created inside Isolate.run(),
// keeping the main/UI thread completely unblocked during inference.
// ─────────────────────────────────────────────────────────────────────────────

class MlService {
  MlService._();
  static final MlService instance = MlService._();

  Uint8List? _modelBytes;
  bool get isModelLoaded => _modelBytes != null;

  Future<void> initialize() async {
    debugPrint('[MlService] initialize() called');
    try {
      final data = await rootBundle.load(AppConstants.regressionModelPath);
      _modelBytes = data.buffer.asUint8List();
      debugPrint('[MlService] regression_model.tflite loaded — '
          '${(_modelBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB');
    } catch (e, stack) {
      debugPrint('[MlService] ⚠️  initialization FAILED: $e');
      debugPrint(stack.toString());
      _modelBytes = null;
    }
    debugPrint('[MlService] isModelLoaded = $isModelLoaded');
  }

  Future<PriceResult> estimatePrice({
    required ProductInput input,
    required NlpScores nlpScores,
  }) async {
    debugPrint('[MlService] estimatePrice() called');
    debugPrint('[MlService]   category      : ${input.category.label}');
    debugPrint('[MlService]   brand/model   : "${input.brand}" "${input.model}"');
    debugPrint('[MlService]   originalPrice : ₹${input.originalPrice}');
    debugPrint('[MlService]   ageInMonths   : ${input.ageInMonths}');
    debugPrint('[MlService]   condition%    : ${input.conditionPercent}');
    debugPrint('[MlService]   damage        : ${input.hasPhysicalDamage}  '
        'issues: ${input.hasFunctionalIssues}  '
        'accessories: ${input.accessoriesIncluded}');
    debugPrint('[MlService]   marketPrice   : ${input.currentMarketPrice}');
    debugPrint('[MlService]   extras        : ${input.extras.toJson()}');
    debugPrint('[MlService]   nlpScores     : urgency=${nlpScores.urgencyScore}  '
        'condition=${nlpScores.conditionScore}  '
        'confidence=${nlpScores.confidence}');
    debugPrint('[MlService] isModelLoaded=$isModelLoaded → '
        '${isModelLoaded ? "TFLite isolate" : "heuristic fallback"}');

    final payload = _MlPayload(
      modelBytes: _modelBytes,
      input: input,
      nlpScores: nlpScores,
    );
    // Runs entirely off the main thread — no UI freeze.
    final result = await Isolate.run(() => _runRegression(payload));
    debugPrint('[MlService] result → '
        'suggested=₹${result.suggestedPrice}  '
        'range=[₹${result.minPrice}, ₹${result.maxPrice}]  '
        'confidence=${result.confidenceScore}');
    return result;
  }
}

// ─── Isolate Payload ──────────────────────────────────────────────────────────
// All fields must be Dart-isolate-sendable (primitives, Uint8List, etc.).

class _MlPayload {
  final Uint8List? modelBytes;
  final ProductInput input;
  final NlpScores nlpScores;
  const _MlPayload({
    required this.modelBytes,
    required this.input,
    required this.nlpScores,
  });
}

// ─── Regression (runs in isolate) ─────────────────────────────────────────────

PriceResult _runRegression(_MlPayload p) {
  double basePrice;

  if (p.modelBytes != null) {
    debugPrint('[MlIsolate] model bytes present '
        '(${(p.modelBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB) '
        '— attempting TFLite inference');
    try {
      final interpreter = Interpreter.fromBuffer(p.modelBytes!);
      debugPrint('[MlIsolate] Interpreter.fromBuffer() succeeded');
      basePrice = _tfliteInference(interpreter, p.input, p.nlpScores);
      interpreter.close();
      debugPrint('[MlIsolate] TFLite inference complete ✓  basePrice=₹$basePrice');
    } catch (e) {
      debugPrint('[MlIsolate] ⚠️  TFLite FAILED: $e — falling back to heuristic');
      basePrice = _heuristicRegression(p.input, p.nlpScores);
    }
  } else {
    debugPrint('[MlIsolate] no model bytes — using heuristic regression');
    basePrice = _heuristicRegression(p.input, p.nlpScores);
  }

  final minPrice = basePrice * AppConstants.minPriceMultiplier;
  final maxPrice = basePrice * AppConstants.maxPriceMultiplier;
  final confidence =
      (p.nlpScores.confidence * 0.6 + p.input.conditionNormalized * 0.4)
          .clamp(0.3, 0.95);

  debugPrint('[MlIsolate] final → base=₹$basePrice  '
      'min=₹$minPrice  max=₹$maxPrice  confidence=$confidence');

  return PriceResult(
    minPrice: _roundToNearest(minPrice, 500),
    maxPrice: _roundToNearest(maxPrice, 500),
    suggestedPrice: _roundToNearest(basePrice, 100),
    confidenceScore: double.parse(confidence.toStringAsFixed(2)),
    nlpScores: p.nlpScores,
    input: p.input,
    estimatedAt: DateTime.now(),
  );
}

double _tfliteInference(
    Interpreter interpreter, ProductInput input, NlpScores nlp) {
  final featureVector = [
    input.originalPrice / 200000,
    input.ageInMonths / 120.0,
    input.conditionNormalized,
    input.damageFlagDouble,
    input.issueFlagDouble,
    input.accessoriesFlagDouble,
    input.category.encoded / 3.0,
    nlp.urgencyScore,
    nlp.conditionScore,
  ];
  debugPrint('[MlIsolate] TFLite feature vector: $featureVector');

  final inputTensor  = [featureVector];
  final outputBuffer = [List.filled(1, 0.0)];
  interpreter.run(inputTensor, outputBuffer);

  final rawRatio = outputBuffer[0][0];
  final ratio    = rawRatio.clamp(0.05, 0.98);
  debugPrint('[MlIsolate] TFLite raw output ratio=$rawRatio  clamped=$ratio');

  return input.originalPrice * ratio;
}

// ─── Heuristic Regression ─────────────────────────────────────────────────────

double _heuristicRegression(ProductInput input, NlpScores nlp) {
  debugPrint('[MlIsolate] *** HEURISTIC REGRESSION ACTIVE (not TFLite) ***');

  final lambda    = _depreciationRate(input.category.encoded);
  final ageFactor = math.exp(-lambda * input.ageInMonths);

  final conditionMult =
      (input.conditionNormalized * 0.7 + nlp.conditionScore * 0.3)
          .clamp(0.05, 1.0);

  final damagePenalty    = input.hasPhysicalDamage    ? 0.88 : 1.0;
  final issuePenalty     = input.hasFunctionalIssues  ? 0.82 : 1.0;
  final accessoriesBonus = input.accessoriesIncluded  ? 1.04 : 1.0;
  final urgencyMult      = 1.0 - (nlp.urgencyScore - 0.5) * 0.18;
  final brandMult        = _brandMultiplier(input.brand, input.category.encoded);
  final extrasMult       = _extrasMultiplier(input);

  double marketAnchor = 1.0;
  if (input.currentMarketPrice != null && input.currentMarketPrice! > 0) {
    final ratio = input.currentMarketPrice! / input.originalPrice;
    marketAnchor = 0.85 + ratio * 0.15;
  }

  debugPrint('[MlIsolate] heuristic factors:'
      '\n  ageFactor=$ageFactor (λ=$lambda, age=${input.ageInMonths}mo)'
      '\n  conditionMult=$conditionMult'
      '\n  damagePenalty=$damagePenalty  issuePenalty=$issuePenalty'
      '\n  accessoriesBonus=$accessoriesBonus  urgencyMult=$urgencyMult'
      '\n  brandMult=$brandMult (brand="${input.brand}")'
      '\n  extrasMult=$extrasMult  marketAnchor=$marketAnchor');

  final base = input.originalPrice *
      ageFactor *
      conditionMult *
      damagePenalty *
      issuePenalty *
      accessoriesBonus *
      urgencyMult *
      brandMult *
      extrasMult *
      marketAnchor;

  final clamped = base.clamp(
      input.originalPrice * 0.05, input.originalPrice * 0.98);
  debugPrint('[MlIsolate] heuristic base=₹$base  clamped=₹$clamped');
  return clamped;
}

// ─── Brand Premium ────────────────────────────────────────────────────────────

double _brandMultiplier(String brand, int cat) {
  final b = brand.toLowerCase().trim();
  switch (cat) {
    case 0: // Mobile
      if (_has(b, ['apple', 'iphone'])) return 1.22;
      if (_has(b, ['samsung']) &&
          _has(b, ['ultra', 'fold', 'flip', 's2', 's23', 's24', 's25'])) { return 1.12; }
      if (_has(b, ['samsung'])) return 1.06;
      if (_has(b, ['google', 'pixel'])) return 1.10;
      if (_has(b, ['oneplus'])) return 1.04;
      if (_has(b, ['sony'])) return 1.05;
      if (_has(b, ['xiaomi', 'redmi', 'poco', 'realme', 'oppo', 'vivo',
          'tecno', 'infinix', 'itel'])) { return 0.94; }
      return 1.0;

    case 1: // Bike
      if (_has(b, ['royal enfield', 'royal_enfield', 're'])) return 1.18;
      if (_has(b, ['ktm'])) return 1.15;
      if (_has(b, ['bmw', 'ducati', 'triumph', 'harley'])) return 1.20;
      if (_has(b, ['yamaha', 'suzuki'])) return 1.04;
      if (_has(b, ['honda', 'hero', 'tvs', 'bajaj'])) return 1.0;
      return 1.0;

    case 2: // Cycle
      if (_has(b, ['trek', 'specialized', 'giant', 'cannondale',
          'scott', 'merida'])) { return 1.15; }
      if (_has(b, ['firefox', 'btwin', 'rockrider'])) return 1.05;
      return 1.0;

    case 3: // Home Appliance
      if (_has(b, ['bosch', 'siemens', 'miele'])) return 1.10;
      if (_has(b, ['lg', 'samsung', 'whirlpool', 'hitachi'])) return 1.05;
      if (_has(b, ['voltas', 'carrier', 'daikin', 'blue star',
          'bluestar'])) { return 1.03; }
      return 1.0;

    default:
      return 1.0;
  }
}

bool _has(String text, List<String> keywords) =>
    keywords.any((k) => text.contains(k));

// ─── Category-Specific Extras Multiplier ─────────────────────────────────────

double _extrasMultiplier(ProductInput input) {
  double mult = 1.0;
  final x = input.extras;

  switch (input.category.encoded) {
    case 0: // Mobile — storage, battery health
      mult *= _storageFactor(x.storage);
      mult *= _batteryFactor(x.batteryHealth);

    case 1: // Bike — km driven, insurance
      mult *= _kmFactor(x.kmDriven);
      if (x.insuranceValid == true)  mult *= 1.03;
      if (x.rcAvailable == false)    mult *= 0.93;

    case 2: // Cycle — km driven
      mult *= _kmFactor(x.kmDriven, isCycle: true);

    case 3: // Home Appliance — star rating
      mult *= _starFactor(x.energyStarRating);
  }

  return mult;
}

double _storageFactor(String? storage) {
  return switch (storage) {
    '32GB'  => 0.90,
    '64GB'  => 0.95,
    '128GB' => 1.00,
    '256GB' => 1.07,
    '512GB' => 1.14,
    '1TB'   => 1.20,
    _       => 1.00,
  };
}

double _batteryFactor(double? health) {
  if (health == null) return 1.0;
  // Each 10% below 100% → ~2.5% price reduction
  return (1.0 - (100 - health) / 100.0 * 0.25).clamp(0.70, 1.0);
}

double _kmFactor(int? km, {bool isCycle = false}) {
  if (km == null) return 1.0;
  if (isCycle) {
    if (km < 500)  return 1.02;
    if (km < 2000) return 0.97;
    if (km < 5000) return 0.91;
    return 0.84;
  }
  // Bike
  if (km < 5000)  return 1.02;
  if (km < 15000) return 0.96;
  if (km < 30000) return 0.88;
  if (km < 50000) return 0.80;
  return 0.70;
}

double _starFactor(int? stars) {
  if (stars == null) return 1.0;
  // 5-star appliance holds value ~8% better than 1-star
  return 0.94 + stars * 0.014;
}

double _depreciationRate(int cat) =>
    const [0.040, 0.018, 0.015, 0.012][cat.clamp(0, 3)];

double _roundToNearest(double value, double nearest) =>
    (value / nearest).round() * nearest;
