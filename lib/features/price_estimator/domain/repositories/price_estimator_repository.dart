import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';
import 'package:vittalo/features/price_estimator/domain/entities/product_input.dart';

// ─── Price Estimator Repository Contract ─────────────────────────────────────

abstract interface class PriceEstimatorRepository {
  /// Runs the full ML + NLP pipeline for [input] and returns [PriceResult].
  Future<PriceResult> estimatePrice(ProductInput input);

  /// Returns the last N saved estimations from local storage.
  Future<List<PriceResult>> getEstimationHistory({int limit = 10});

  /// Persists [result] to local storage.
  Future<void> saveEstimation(PriceResult result);

  /// Clears all stored estimations.
  Future<void> clearHistory();
}
