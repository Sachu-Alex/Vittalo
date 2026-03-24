// ─── NLP Scores Entity ────────────────────────────────────────────────────────

class NlpScores {
  /// 0.0–1.0 — how urgently the seller needs to sell
  final double urgencyScore;

  /// 0.0–1.0 — sentiment about the item's condition (higher = better)
  final double conditionScore;

  /// 0.0–1.0 — model confidence in the NLP prediction
  final double confidence;

  const NlpScores({
    required this.urgencyScore,
    required this.conditionScore,
    required this.confidence,
  });

  /// Neutral fallback when NLP model is unavailable
  static const NlpScores neutral = NlpScores(
    urgencyScore: 0.5,
    conditionScore: 0.6,
    confidence: 0.4,
  );

  String get urgencyLabel {
    if (urgencyScore >= 0.7) return 'High';
    if (urgencyScore >= 0.4) return 'Medium';
    return 'Low';
  }

  String get conditionLabel {
    if (conditionScore >= 0.75) return 'Excellent';
    if (conditionScore >= 0.5) return 'Good';
    if (conditionScore >= 0.3) return 'Fair';
    return 'Poor';
  }

  NlpScores copyWith({
    double? urgencyScore,
    double? conditionScore,
    double? confidence,
  }) {
    return NlpScores(
      urgencyScore: urgencyScore ?? this.urgencyScore,
      conditionScore: conditionScore ?? this.conditionScore,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  String toString() =>
      'NlpScores(urgency: $urgencyScore, condition: $conditionScore, confidence: $confidence)';
}
