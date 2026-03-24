import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/core/router/app_router.dart';
import 'package:vittalo/core/theme/app_theme.dart';
import 'package:vittalo/features/category_selection/domain/models/category_model.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _Header(),
              const SizedBox(height: 36),
              Expanded(child: _CategoryGrid()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: VittaloColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: VittaloColors.primary, size: 14),
              const SizedBox(width: 6),
              Text(
                'AI Price Estimator',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: VittaloColors.primaryLight,
                      letterSpacing: 0.6,
                    ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.2, end: 0, duration: 400.ms),
        const SizedBox(height: 14),
        Text(
          'What are you\nselling today?',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                height: 1.15,
              ),
        )
            .animate(delay: 100.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0, duration: 500.ms),
        const SizedBox(height: 8),
        Text(
          'Choose a category to get your AI-powered price estimate.',
          style: Theme.of(context).textTheme.bodyMedium,
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 400.ms),
      ],
    );
  }
}

// ─── Category Grid ────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: CategoryModel.all.length,
      itemBuilder: (context, index) {
        return _CategoryCard(
          model: CategoryModel.all[index],
          index: index,
        );
      },
    );
  }
}

// ─── Category Card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatefulWidget {
  final CategoryModel model;
  final int index;

  const _CategoryCard({required this.model, required this.index});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  void _onTap() {
    context.push(AppRoutes.imageUpload, extra: widget.model);
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: AppConstants.animDurationFast,
        child: Container(
          decoration: BoxDecoration(
            color: VittaloColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(
              color: _pressed ? model.accentColor : VittaloColors.cardBorder,
              width: _pressed ? 1.5 : 1,
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: model.accentColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: model.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      model.icon,
                      color: model.accentColor,
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  model.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  model.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Arrow chip
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Estimate',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: model.accentColor,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: model.accentColor,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: (widget.index * 80).ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),
    );
  }
}
