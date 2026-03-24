import 'package:flutter/foundation.dart';
import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';
import 'package:vittalo/features/price_estimator/domain/entities/product_input.dart';
import 'package:vittalo/features/price_estimator/domain/repositories/price_estimator_repository.dart';
import 'package:vittalo/features/price_estimator/data/local/estimator_storage.dart';
import 'package:vittalo/services/ml_service.dart';
import 'package:vittalo/services/nlp_service.dart';

// ─── Price Estimator Repository Implementation ───────────────────────────────

class PriceEstimatorRepositoryImpl implements PriceEstimatorRepository {
  final MlService _mlService;
  final NlpService _nlpService;
  final EstimatorStorage _storage;

  PriceEstimatorRepositoryImpl({
    required MlService mlService,
    required NlpService nlpService,
    required EstimatorStorage storage,
  })  : _mlService = mlService,
        _nlpService = nlpService,
        _storage = storage;

  @override
  Future<PriceResult> estimatePrice(ProductInput input) async {
    debugPrint('[Repository] ── estimatePrice START ──────────────────────');
    debugPrint('[Repository] nlpService.isModelLoaded  = ${_nlpService.isModelLoaded}');
    debugPrint('[Repository] mlService.isModelLoaded   = ${_mlService.isModelLoaded}');

    // Step 1 — NLP: analyse seller text → scores
    debugPrint('[Repository] Step 1: NLP analysis…');
    final nlpScores = await _nlpService.analyze(
      reasonForSelling: input.reasonForSelling,
      conditionDescription: input.conditionDescription,
    );
    debugPrint('[Repository] Step 1 done → $nlpScores');

    // Step 2 — Regression: structured features + NLP scores → price
    debugPrint('[Repository] Step 2: ML regression…');
    final result = await _mlService.estimatePrice(
      input: input,
      nlpScores: nlpScores,
    );
    debugPrint('[Repository] Step 2 done → suggested=₹${result.suggestedPrice}');

    // Step 3 — Persist locally
    debugPrint('[Repository] Step 3: persisting result…');
    await _storage.save(result);
    debugPrint('[Repository] ── estimatePrice END ────────────────────────');

    return result;
  }

  @override
  Future<List<PriceResult>> getEstimationHistory({int limit = 10}) {
    return _storage.getHistory(limit: limit);
  }

  @override
  Future<void> saveEstimation(PriceResult result) {
    return _storage.save(result);
  }

  @override
  Future<void> clearHistory() {
    return _storage.clear();
  }
}
