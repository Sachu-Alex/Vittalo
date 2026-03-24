import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/core/router/app_router.dart';
import 'package:vittalo/core/theme/app_theme.dart';
import 'package:vittalo/features/category_selection/domain/models/category_model.dart';
import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';
import 'package:vittalo/features/price_estimator/presentation/screens/input_wizard_screen.dart';
import 'package:vittalo/features/price_estimator/presentation/widgets/price_range_card.dart';

class ResultScreen extends StatelessWidget {
  final PriceResult result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.categorySelection),
        ),
        title: const Text('Price Estimate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareResult(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SuggestedPriceCard(result: result),
                const SizedBox(height: 20),
                PriceRangeCard(result: result),
                const SizedBox(height: 20),
                _ConfidenceCard(result: result),
                const SizedBox(height: 20),
                _AiInsightsCard(result: result),
                const SizedBox(height: 20),
                _ProductSummaryCard(result: result),
                const SizedBox(height: 28),
                _EditReEstimateButton(result: result),
                const SizedBox(height: 12),
                _NewEstimateButton(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResult(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Share: ${result.input.brand} ${result.input.model} — '
          'Suggested ${fmt.format(result.suggestedPrice)}',
        ),
      ),
    );
  }
}

// ─── Suggested Price Hero Card ────────────────────────────────────────────────

class _SuggestedPriceCard extends StatelessWidget {
  final PriceResult result;
  const _SuggestedPriceCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: VittaloColors.priceCardGradient,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: VittaloColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: VittaloColors.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: VittaloColors.gold, size: 16),
              const SizedBox(width: 6),
              Text(
                'AI RECOMMENDED PRICE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: VittaloColors.gold,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) =>
                VittaloColors.goldGradient.createShader(bounds),
            child: Text(
              fmt.format(result.suggestedPrice),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 8),
          Text(
            '${result.input.brand} ${result.input.model}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${result.input.ageInMonths} months old · '
            '${result.input.conditionPercent.round()}% condition',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: VittaloColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${result.depreciationPercent.toStringAsFixed(1)}% depreciation from original price',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: VittaloColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }
}

// ─── Confidence Card ──────────────────────────────────────────────────────────

class _ConfidenceCard extends StatelessWidget {
  final PriceResult result;
  const _ConfidenceCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result.confidenceScore;
    final color = score >= 0.7
        ? VittaloColors.secondary
        : score >= 0.5
            ? VittaloColors.warning
            : VittaloColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VittaloColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: VittaloColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(score * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.confidenceLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: VittaloColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score,
                    backgroundColor: VittaloColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }
}

// ─── AI Insights Card ─────────────────────────────────────────────────────────

class _AiInsightsCard extends StatelessWidget {
  final PriceResult result;
  const _AiInsightsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final insights = result.aiInsights;
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VittaloColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: VittaloColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  color: VittaloColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: VittaloColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle,
                      size: 6, color: VittaloColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: VittaloColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NlpChip(
                label: 'Urgency',
                value: result.nlpScores.urgencyLabel,
                color: result.nlpScores.urgencyScore >= 0.7
                    ? VittaloColors.error
                    : result.nlpScores.urgencyScore >= 0.4
                        ? VittaloColors.warning
                        : VittaloColors.secondary,
              ),
              _NlpChip(
                label: 'Condition',
                value: result.nlpScores.conditionLabel,
                color: result.nlpScores.conditionScore >= 0.7
                    ? VittaloColors.secondary
                    : result.nlpScores.conditionScore >= 0.4
                        ? VittaloColors.warning
                        : VittaloColors.error,
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }
}

class _NlpChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _NlpChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: VittaloColors.textDisabled,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Product Summary Card ─────────────────────────────────────────────────────

class _ProductSummaryCard extends StatelessWidget {
  final PriceResult result;
  const _ProductSummaryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final input = result.input;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VittaloColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: VittaloColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product Summary',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 14),
          _SummaryRow('Original Price', fmt.format(input.originalPrice)),
          _SummaryRow('Age', '${input.ageInMonths} months'),
          _SummaryRow('Category', input.category.label),
          _SummaryRow('Condition', '${input.conditionPercent.round()}%'),
          _SummaryRow('Physical Damage', input.hasPhysicalDamage ? 'Yes' : 'No'),
          _SummaryRow('Functional Issues', input.hasFunctionalIssues ? 'Yes' : 'No'),
          _SummaryRow('Accessories', input.accessoriesIncluded ? 'Included' : 'Not included'),
          _SummaryRow(
            'Estimated on',
            DateFormat('dd MMM yyyy, hh:mm a').format(result.estimatedAt),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: VittaloColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Edit & Re-Estimate Button ────────────────────────────────────────────────

class _EditReEstimateButton extends StatelessWidget {
  final PriceResult result;
  const _EditReEstimateButton({required this.result});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          final categoryModel = CategoryModel.all.firstWhere(
            (m) => m.category == result.input.category,
          );
          context.push(
            AppRoutes.inputWizard,
            extra: InputWizardArgs(
              category: categoryModel,
              imagePath: result.input.imagePath,
              prefill: result.input,
            ),
          );
        },
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text('Edit & Re-estimate'),
        style: OutlinedButton.styleFrom(
          foregroundColor: VittaloColors.primary,
          side: const BorderSide(color: VittaloColors.primary),
        ),
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms);
  }
}

// ─── New Estimate Button ──────────────────────────────────────────────────────

class _NewEstimateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRoutes.categorySelection),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Estimate'),
      ),
    ).animate(delay: 650.ms).fadeIn(duration: 400.ms);
  }
}
