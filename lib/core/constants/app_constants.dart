// ─── Vittalo App Constants ────────────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Vittalo';
  static const String appTagline = 'Sell smarter, not cheaper';

  // Asset Paths
  static const String logoPath = 'assets/images/vittalo_logo.png';
  static const String regressionModelPath = 'assets/models/regression_model.tflite';
  static const String bertTinyModelPath = 'assets/models/bert_tiny.tflite';

  // ML Configuration
  static const int bertMaxSequenceLength = 128;
  static const int bertVocabSize = 30522;
  static const int regressionInputSize = 9;

  // Price post-processing multipliers
  static const double minPriceMultiplier = 0.85;
  static const double maxPriceMultiplier = 1.15;

  // Inference timeout (ms)
  static const int inferenceTimeoutMs = 5000;

  // Hive Box Names
  static const String estimationHistoryBox = 'estimation_history';
  static const String settingsBox = 'settings';

  // Urgency score thresholds (NLP output)
  static const double urgencyLow = 0.2;
  static const double urgencyMedium = 0.5;
  static const double urgencyHigh = 0.9;

  // Condition sentiment thresholds
  static const double conditionPoor = 0.3;
  static const double conditionFair = 0.6;
  static const double conditionGood = 0.9;

  // UI
  static const double cardRadius = 20.0;
  static const double buttonRadius = 14.0;
  static const double pagePadding = 20.0;
  static const Duration animDurationFast = Duration(milliseconds: 200);
  static const Duration animDurationMed = Duration(milliseconds: 350);
  static const Duration animDurationSlow = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(milliseconds: 2800);
}

// Category encoding for ML input vector
enum ProductCategory {
  mobile(encoded: 0, label: 'Mobile', icon: '📱'),
  bike(encoded: 1, label: 'Bike', icon: '🏍️'),
  cycle(encoded: 2, label: 'Cycle', icon: '🚲'),
  homeAppliance(encoded: 3, label: 'Home Appliance', icon: '🏠');

  const ProductCategory({
    required this.encoded,
    required this.label,
    required this.icon,
  });

  final int encoded;
  final String label;
  final String icon;
}
