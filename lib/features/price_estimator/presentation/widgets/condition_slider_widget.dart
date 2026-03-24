import 'package:flutter/material.dart';
import 'package:vittalo/core/theme/app_theme.dart';

class ConditionSliderWidget extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const ConditionSliderWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = _label(value);
    final color = _color(value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VittaloColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VittaloColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.round()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: Colors.white,
              overlayColor: color.withValues(alpha: 0.15),
              inactiveTrackColor: VittaloColors.cardBorder,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Poor',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: VittaloColors.error)),
              Text('Like New',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: VittaloColors.secondary)),
            ],
          ),
        ],
      ),
    );
  }

  String _label(double v) {
    if (v >= 85) return 'Like New';
    if (v >= 70) return 'Good';
    if (v >= 50) return 'Fair';
    if (v >= 30) return 'Poor';
    return 'For Parts';
  }

  Color _color(double v) {
    if (v >= 85) return VittaloColors.secondary;
    if (v >= 70) return const Color(0xFF66BB6A);
    if (v >= 50) return VittaloColors.warning;
    if (v >= 30) return const Color(0xFFFF8A65);
    return VittaloColors.error;
  }
}
