import 'package:flutter/material.dart';
import 'package:vittalo/core/theme/app_theme.dart';

class WizardProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const WizardProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isCompleted || isActive
                      ? VittaloColors.primary
                      : VittaloColors.cardBorder,
                  gradient: isActive
                      ? VittaloColors.primaryGradient
                      : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
