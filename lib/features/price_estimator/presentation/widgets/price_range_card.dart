import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/core/theme/app_theme.dart';
import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';

class PriceRangeCard extends StatelessWidget {
  final PriceResult result;
  const PriceRangeCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final range = result.maxPrice - result.minPrice;
    final suggestedOffset = range > 0
        ? (result.suggestedPrice - result.minPrice) / range
        : 0.5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VittaloColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: VittaloColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 20),

          // Min / Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PriceLabel(
                label: 'Minimum',
                price: fmt.format(result.minPrice),
                color: VittaloColors.error,
              ),
              _PriceLabel(
                label: 'Maximum',
                price: fmt.format(result.maxPrice),
                color: VittaloColors.secondary,
                alignRight: true,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Range bar
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final thumbX = (suggestedOffset * width).clamp(12.0, width - 12.0);

              return SizedBox(
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Track
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(
                          colors: [
                            VittaloColors.error,
                            VittaloColors.warning,
                            VittaloColors.secondary,
                          ],
                        ),
                      ),
                    ),
                    // Suggested price thumb
                    Positioned(
                      left: thumbX - 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: VittaloColors.primary, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: VittaloColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Suggested marker label centered
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: VittaloColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: VittaloColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.recommend_rounded,
                      size: 14, color: VittaloColors.primaryLight),
                  const SizedBox(width: 6),
                  Text(
                    'Suggested: ${fmt.format(result.suggestedPrice)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: VittaloColors.primaryLight,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 450.ms);
  }
}

class _PriceLabel extends StatelessWidget {
  final String label;
  final String price;
  final Color color;
  final bool alignRight;

  const _PriceLabel({
    required this.label,
    required this.price,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: VittaloColors.textDisabled,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          price,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
