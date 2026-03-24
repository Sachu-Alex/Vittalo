import 'package:vittalo/features/price_estimator/domain/entities/nlp_scores.dart';
import 'package:vittalo/features/price_estimator/domain/entities/product_input.dart';

// ─── Price Result Entity ──────────────────────────────────────────────────────

class PriceResult {
  final double minPrice;
  final double maxPrice;
  final double suggestedPrice;
  final double confidenceScore;
  final NlpScores nlpScores;
  final ProductInput input;
  final DateTime estimatedAt;

  const PriceResult({
    required this.minPrice,
    required this.maxPrice,
    required this.suggestedPrice,
    required this.confidenceScore,
    required this.nlpScores,
    required this.input,
    required this.estimatedAt,
  });

  /// Confidence label derived from score
  String get confidenceLabel {
    if (confidenceScore >= 0.8) return 'High Confidence';
    if (confidenceScore >= 0.55) return 'Moderate Confidence';
    return 'Low Confidence';
  }

  /// Human-readable AI insights based on NLP scores
  List<String> get aiInsights {
    final insights = <String>[];

    if (nlpScores.urgencyScore >= 0.7) {
      insights.add('High urgency detected — price adjusted competitively');
    } else if (nlpScores.urgencyScore <= 0.3) {
      insights.add('No urgency — you can hold out for a better price');
    }

    if (nlpScores.conditionScore >= 0.75) {
      insights.add('Condition appears excellent — premium pricing supported');
    } else if (nlpScores.conditionScore >= 0.45) {
      insights.add('Condition appears moderate — fair market pricing applied');
    } else {
      insights.add('Significant wear detected — price adjusted downward');
    }

    if (input.hasPhysicalDamage) {
      insights.add('Physical damage factored into price reduction');
    }
    if (input.hasFunctionalIssues) {
      insights.add('Functional issues reduce resale value');
    }
    if (input.accessoriesIncluded) {
      insights.add('Included accessories boost buyer appeal');
    }

    return insights;
  }

  /// Depreciation percentage from original price
  double get depreciationPercent {
    if (input.originalPrice <= 0) return 0;
    return ((input.originalPrice - suggestedPrice) / input.originalPrice * 100)
        .clamp(0, 100);
  }

  PriceResult copyWith({
    double? minPrice,
    double? maxPrice,
    double? suggestedPrice,
    double? confidenceScore,
    NlpScores? nlpScores,
    ProductInput? input,
    DateTime? estimatedAt,
  }) {
    return PriceResult(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      nlpScores: nlpScores ?? this.nlpScores,
      input: input ?? this.input,
      estimatedAt: estimatedAt ?? this.estimatedAt,
    );
  }
}
