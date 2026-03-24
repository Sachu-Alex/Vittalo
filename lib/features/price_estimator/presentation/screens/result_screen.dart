import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
                _MarketComparisonCard(result: result),
                const SizedBox(height: 20),
                _DepreciationBreakdownCard(result: result),
                const SizedBox(height: 20),
                _SellSmarterCard(result: result),
                const SizedBox(height: 20),
                _PostToMarketplaceCard(result: result),
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

// ─── Market Comparison Card ───────────────────────────────────────────────────

class _MarketComparisonCard extends StatelessWidget {
  final PriceResult result;
  const _MarketComparisonCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final suggested = result.suggestedPrice;

    // OLX & Quikr sellers typically list 15–35% higher to leave room for negotiation
    final olxLow = suggested * 1.15;
    final olxHigh = suggested * 1.35;
    final quikrLow = suggested * 1.10;
    final quikrHigh = suggested * 1.30;

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
              const Icon(Icons.compare_arrows_rounded,
                  color: VittaloColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Market Comparison',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Similar items currently listed on resale platforms',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: VittaloColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _MarketRow(
            platform: 'Vittalo AI',
            subtitle: 'Fair market value',
            price: fmt.format(suggested),
            color: VittaloColors.primary,
            isPrimary: true,
          ),
          const SizedBox(height: 10),
          _MarketRow(
            platform: 'OLX',
            subtitle: 'Typical listing range',
            price: '${fmt.format(olxLow)} – ${fmt.format(olxHigh)}',
            color: const Color(0xFF006AFF),
            isPrimary: false,
          ),
          const SizedBox(height: 10),
          _MarketRow(
            platform: 'Quikr',
            subtitle: 'Typical listing range',
            price: '${fmt.format(quikrLow)} – ${fmt.format(quikrHigh)}',
            color: const Color(0xFF00B140),
            isPrimary: false,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: VittaloColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: VittaloColors.gold.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: VittaloColors.gold, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'OLX & Quikr sellers list ${((olxLow / suggested - 1) * 100).round()}–${((olxHigh / suggested - 1) * 100).round()}% higher than fair value. '
                    'That\'s negotiation buffer — buyers will bargain down. '
                    'List at the higher range and settle near our AI estimate.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: VittaloColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }
}

class _MarketRow extends StatelessWidget {
  final String platform;
  final String subtitle;
  final String price;
  final Color color;
  final bool isPrimary;

  const _MarketRow({
    required this.platform,
    required this.subtitle,
    required this.price,
    required this.color,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPrimary ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border:
            isPrimary ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(platform,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      )),
              Text(subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: VittaloColors.textDisabled,
                      )),
            ],
          ),
          Text(price,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isPrimary ? color : VittaloColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )),
        ],
      ),
    );
  }
}

// ─── Depreciation Breakdown Card ─────────────────────────────────────────────

class _DepreciationBreakdownCard extends StatelessWidget {
  final PriceResult result;
  const _DepreciationBreakdownCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final input = result.input;

    final factors = <_DepFactor>[];

    final months = input.ageInMonths;
    if (months <= 6) {
      factors.add(_DepFactor('Age', '$months months — nearly new', 0.12,
          VittaloColors.secondary));
    } else if (months <= 18) {
      factors.add(_DepFactor(
          'Age', '$months months — light use', 0.35, VittaloColors.warning));
    } else if (months <= 36) {
      factors.add(_DepFactor(
          'Age', '$months months — regular use', 0.55, VittaloColors.warning));
    } else {
      factors.add(_DepFactor(
          'Age', '$months months — heavy use', 0.80, VittaloColors.error));
    }

    final cond = input.conditionPercent;
    if (cond >= 80) {
      factors.add(_DepFactor('Condition', '${cond.round()}% — excellent', 0.15,
          VittaloColors.secondary));
    } else if (cond >= 60) {
      factors.add(_DepFactor(
          'Condition', '${cond.round()}% — good', 0.40, VittaloColors.warning));
    } else if (cond >= 40) {
      factors.add(_DepFactor(
          'Condition', '${cond.round()}% — fair', 0.60, VittaloColors.warning));
    } else {
      factors.add(_DepFactor(
          'Condition', '${cond.round()}% — poor', 0.80, VittaloColors.error));
    }

    if (input.hasPhysicalDamage) {
      factors.add(_DepFactor('Physical Damage', 'Visible damage detected',
          0.75, VittaloColors.error));
    }
    if (input.hasFunctionalIssues) {
      factors.add(_DepFactor('Functional Issues', 'Performance affected', 0.85,
          VittaloColors.error));
    }
    if (!input.accessoriesIncluded) {
      factors.add(_DepFactor('No Accessories', 'Box/charger missing', 0.30,
          VittaloColors.warning));
    }

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
              const Icon(Icons.help_outline_rounded,
                  color: VittaloColors.warning, size: 18),
              const SizedBox(width: 8),
              Text('Why this price?',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 14),
          // Original → Estimated flow
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Original Price',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: VittaloColors.textDisabled)),
                    const SizedBox(height: 2),
                    Text(fmt.format(input.originalPrice),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                )),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.arrow_forward_rounded,
                      color: VittaloColors.error, size: 18),
                  Text(
                    '−${result.depreciationPercent.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: VittaloColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Estimated Price',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: VittaloColors.textDisabled)),
                    const SizedBox(height: 2),
                    Text(fmt.format(result.suggestedPrice),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: VittaloColors.primary,
                                  fontWeight: FontWeight.w700,
                                )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Lost ${fmt.format(input.originalPrice - result.suggestedPrice)} in value',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: VittaloColors.error),
            ),
          ),
          const Divider(height: 24),
          Text(
            'FACTORS AFFECTING VALUE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: VittaloColors.textDisabled,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 12),
          ...factors.map((f) => _DepreciationFactorRow(factor: f)),
        ],
      ),
    ).animate(delay: 350.ms).fadeIn(duration: 400.ms);
  }
}

class _DepFactor {
  final String label;
  final String subtitle;
  final double impact;
  final Color color;
  const _DepFactor(this.label, this.subtitle, this.impact, this.color);
}

class _DepreciationFactorRow extends StatelessWidget {
  final _DepFactor factor;
  const _DepreciationFactorRow({required this.factor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(factor.label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: VittaloColors.textPrimary)),
              Text(factor.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: VittaloColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor.impact,
              minHeight: 5,
              backgroundColor: VittaloColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(factor.color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sell Smarter Card ────────────────────────────────────────────────────────

class _SellSmarterCard extends StatelessWidget {
  final PriceResult result;
  const _SellSmarterCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final tips = _buildTips();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VittaloColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
            color: VittaloColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: VittaloColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'How to Sell at a Better Price',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: VittaloColors.secondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: VittaloColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(tip.icon,
                        color: VittaloColors.secondary, size: 15),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: VittaloColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                )),
                        const SizedBox(height: 2),
                        Text(tip.desc,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: VittaloColors.textSecondary,
                                  height: 1.5,
                                )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 450.ms).fadeIn(duration: 400.ms);
  }

  List<_Tip> _buildTips() {
    final tips = <_Tip>[
      const _Tip(
        Icons.photo_camera_rounded,
        'Take quality photos in good lighting',
        'Clear photos from multiple angles get 3× more inquiries than blurry ones.',
      ),
      const _Tip(
        Icons.tune_rounded,
        'List 10–15% above your minimum',
        'Buyers always negotiate. Build in room so you still get what you want after bargaining.',
      ),
    ];

    if (!result.input.accessoriesIncluded) {
      tips.add(const _Tip(
        Icons.inventory_2_rounded,
        'Find and include accessories',
        'Original box, charger & cables can add ₹500–₹2,000 to your final price.',
      ));
    }

    if (result.input.hasPhysicalDamage || result.input.hasFunctionalIssues) {
      tips.add(const _Tip(
        Icons.build_rounded,
        'Fix minor issues before listing',
        'A small repair costing ₹200–₹500 can recover 2–3× its cost in resale value.',
      ));
    }

    tips.addAll([
      const _Tip(
        Icons.schedule_rounded,
        'Post on weekends (Sat & Sun)',
        'Weekend listings get 40% more views — buyers browse more when they are free.',
      ),
      const _Tip(
        Icons.edit_note_rounded,
        'Write a detailed, honest description',
        'Mention model number, purchase year, and any issues upfront. Trust = faster sale.',
      ),
    ]);

    return tips;
  }
}

class _Tip {
  final IconData icon;
  final String title;
  final String desc;
  const _Tip(this.icon, this.title, this.desc);
}

// ─── Post to Marketplace Card ─────────────────────────────────────────────────

class _PostToMarketplaceCard extends StatelessWidget {
  final PriceResult result;
  const _PostToMarketplaceCard({required this.result});

  String _buildListingText() {
    final fmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final input = result.input;

    final sb = StringBuffer();
    sb.writeln('${input.brand} ${input.model} for Sale');
    sb.writeln('');
    sb.writeln('💰 Asking Price: ${fmt.format(result.suggestedPrice)}');
    sb.writeln('📦 Category: ${input.category.label}');
    sb.writeln('📅 Age: ${input.ageInMonths} months');
    sb.writeln('⭐ Condition: ${input.conditionPercent.round()}%');
    if (!input.hasPhysicalDamage) sb.writeln('✅ No physical damage');
    if (!input.hasFunctionalIssues) sb.writeln('✅ Fully functional');
    if (input.accessoriesIncluded) sb.writeln('📦 All accessories included');
    sb.writeln('');
    sb.writeln('Price estimated by Vittalo AI — fair market value.');
    sb.writeln('DM/call for details. Serious buyers only.');
    return sb.toString();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not open. Make sure the app is installed.')),
        );
      }
    }
  }

  Future<void> _copyListing(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _buildListingText()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing text copied! Paste it in any app.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingText = _buildListingText();
    final encodedText = Uri.encodeComponent(listingText);

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
              const Icon(Icons.rocket_launch_rounded,
                  color: VittaloColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Post & Sell Now',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a platform, then paste your copied listing',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: VittaloColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              _PlatformButton(
                label: 'OLX',
                color: const Color(0xFF006AFF),
                icon: Icons.storefront_rounded,
                onTap: () => _launchUrl('https://www.olx.in/post-ad/', context),
              ),
              _PlatformButton(
                label: 'Quikr',
                color: const Color(0xFF00B140),
                icon: Icons.sell_rounded,
                onTap: () =>
                    _launchUrl('https://www.quikr.com/PostAd', context),
              ),
              _PlatformButton(
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                icon: Icons.facebook_rounded,
                onTap: () => _launchUrl(
                    'https://www.facebook.com/marketplace/create/item',
                    context),
              ),
              _PlatformButton(
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                icon: Icons.message_rounded,
                onTap: () => _launchUrl(
                    'https://api.whatsapp.com/send?text=$encodedText',
                    context),
              ),
              _PlatformButton(
                label: 'Meesho',
                color: const Color(0xFFE91E8C),
                icon: Icons.shopping_bag_rounded,
                onTap: () => _launchUrl('https://www.meesho.com/', context),
              ),
              _PlatformButton(
                label: 'Copy Text',
                color: VittaloColors.primary,
                icon: Icons.copy_rounded,
                onTap: () => _copyListing(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _copyListing(context),
              icon: const Icon(Icons.copy_all_rounded, size: 16),
              label: const Text('Copy Full Listing Text'),
              style: OutlinedButton.styleFrom(
                foregroundColor: VittaloColors.textSecondary,
                side: const BorderSide(color: VittaloColors.cardBorder),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }
}

class _PlatformButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _PlatformButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
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
    ).animate(delay: 550.ms).fadeIn(duration: 400.ms);
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
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms);
  }
}

class _NlpChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _NlpChip(
      {required this.label, required this.value, required this.color});

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
            style:
                Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
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
    final fmt =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
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
          _SummaryRow(
              'Physical Damage', input.hasPhysicalDamage ? 'Yes' : 'No'),
          _SummaryRow(
              'Functional Issues', input.hasFunctionalIssues ? 'Yes' : 'No'),
          _SummaryRow('Accessories',
              input.accessoriesIncluded ? 'Included' : 'Not included'),
          _SummaryRow(
            'Estimated on',
            DateFormat('dd MMM yyyy, hh:mm a').format(result.estimatedAt),
          ),
        ],
      ),
    ).animate(delay: 650.ms).fadeIn(duration: 400.ms);
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
    ).animate(delay: 700.ms).fadeIn(duration: 400.ms);
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
    ).animate(delay: 750.ms).fadeIn(duration: 400.ms);
  }
}
