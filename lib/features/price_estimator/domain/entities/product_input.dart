import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/features/price_estimator/domain/entities/category_extras.dart';

// ─── Product Input Entity ─────────────────────────────────────────────────────

class ProductInput {
  final ProductCategory category;
  final double originalPrice;
  final DateTime purchaseDate;
  final String brand;
  final String model;
  final double conditionPercent;   // 0–100
  final bool hasPhysicalDamage;
  final bool hasFunctionalIssues;
  final bool accessoriesIncluded;
  final double? currentMarketPrice;
  final String reasonForSelling;
  final String conditionDescription;
  final String? imagePath;

  /// Category-specific details (storage/km/star-rating etc.)
  final CategoryExtras extras;

  const ProductInput({
    required this.category,
    required this.originalPrice,
    required this.purchaseDate,
    required this.brand,
    required this.model,
    required this.conditionPercent,
    required this.hasPhysicalDamage,
    required this.hasFunctionalIssues,
    required this.accessoriesIncluded,
    this.currentMarketPrice,
    required this.reasonForSelling,
    required this.conditionDescription,
    this.imagePath,
    this.extras = CategoryExtras.empty,
  });

  int get ageInMonths {
    final diff = DateTime.now().difference(purchaseDate);
    return (diff.inDays / 30.44).round().clamp(0, 600);
  }

  double get conditionNormalized  => conditionPercent / 100.0;
  double get damageFlagDouble     => hasPhysicalDamage   ? 1.0 : 0.0;
  double get issueFlagDouble      => hasFunctionalIssues ? 1.0 : 0.0;
  double get accessoriesFlagDouble => accessoriesIncluded ? 1.0 : 0.0;

  ProductInput copyWith({
    ProductCategory? category,
    double? originalPrice,
    DateTime? purchaseDate,
    String? brand,
    String? model,
    double? conditionPercent,
    bool? hasPhysicalDamage,
    bool? hasFunctionalIssues,
    bool? accessoriesIncluded,
    double? currentMarketPrice,
    String? reasonForSelling,
    String? conditionDescription,
    String? imagePath,
    CategoryExtras? extras,
  }) =>
      ProductInput(
        category: category ?? this.category,
        originalPrice: originalPrice ?? this.originalPrice,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        conditionPercent: conditionPercent ?? this.conditionPercent,
        hasPhysicalDamage: hasPhysicalDamage ?? this.hasPhysicalDamage,
        hasFunctionalIssues: hasFunctionalIssues ?? this.hasFunctionalIssues,
        accessoriesIncluded: accessoriesIncluded ?? this.accessoriesIncluded,
        currentMarketPrice: currentMarketPrice ?? this.currentMarketPrice,
        reasonForSelling: reasonForSelling ?? this.reasonForSelling,
        conditionDescription: conditionDescription ?? this.conditionDescription,
        imagePath: imagePath ?? this.imagePath,
        extras: extras ?? this.extras,
      );
}
