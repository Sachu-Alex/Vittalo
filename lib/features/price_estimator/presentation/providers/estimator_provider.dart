import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittalo/features/price_estimator/data/local/estimator_storage.dart';
import 'package:vittalo/features/price_estimator/data/repositories/price_estimator_repository_impl.dart';
import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';
import 'package:vittalo/features/price_estimator/domain/entities/product_input.dart';
import 'package:vittalo/features/price_estimator/domain/repositories/price_estimator_repository.dart';
import 'package:vittalo/services/ml_service.dart';
import 'package:vittalo/services/nlp_service.dart';

// ─── Singleton Service Providers ─────────────────────────────────────────────

final mlServiceProvider = Provider<MlService>((ref) => MlService.instance);
final nlpServiceProvider = Provider<NlpService>((ref) => NlpService.instance);
final estimatorStorageProvider = Provider<EstimatorStorage>((ref) => EstimatorStorage.instance);

// ─── Repository Provider ──────────────────────────────────────────────────────

final priceEstimatorRepositoryProvider = Provider<PriceEstimatorRepository>((ref) {
  return PriceEstimatorRepositoryImpl(
    mlService: ref.watch(mlServiceProvider),
    nlpService: ref.watch(nlpServiceProvider),
    storage: ref.watch(estimatorStorageProvider),
  );
});

// ─── Estimation State ─────────────────────────────────────────────────────────

sealed class EstimationState {
  const EstimationState();
}

class EstimationIdle extends EstimationState {
  const EstimationIdle();
}

class EstimationLoading extends EstimationState {
  const EstimationLoading();
}

class EstimationSuccess extends EstimationState {
  final PriceResult result;
  const EstimationSuccess(this.result);
}

class EstimationError extends EstimationState {
  final String message;
  const EstimationError(this.message);
}

// ─── Estimator Notifier ───────────────────────────────────────────────────────

class EstimatorNotifier extends StateNotifier<EstimationState> {
  final PriceEstimatorRepository _repository;

  EstimatorNotifier(this._repository) : super(const EstimationIdle());

  Future<void> estimate(ProductInput input) async {
    state = const EstimationLoading();
    try {
      final result = await _repository.estimatePrice(input);
      state = EstimationSuccess(result);
    } catch (e) {
      state = EstimationError(
        'Estimation failed: ${e.toString()}. '
        'Please check your inputs and try again.',
      );
    }
  }

  void reset() => state = const EstimationIdle();
}

final estimatorProvider =
    StateNotifierProvider<EstimatorNotifier, EstimationState>((ref) {
  return EstimatorNotifier(ref.watch(priceEstimatorRepositoryProvider));
});

// ─── History Provider ─────────────────────────────────────────────────────────

final estimationHistoryProvider = FutureProvider<List<PriceResult>>((ref) async {
  final repo = ref.watch(priceEstimatorRepositoryProvider);
  return repo.getEstimationHistory();
});
