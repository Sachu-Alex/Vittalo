import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/core/router/app_router.dart';
import 'package:vittalo/core/theme/app_theme.dart';
import 'package:vittalo/services/ml_service.dart';
import 'package:vittalo/services/nlp_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // Initialise ML services while splash is displayed
    await Future.wait([
      MlService.instance.initialize(),
      NlpService.instance.initialize(),
      Future.delayed(AppConstants.splashDuration),
    ]);
    if (mounted) context.go(AppRoutes.categorySelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: VittaloColors.splashGradient),
        child: Stack(
          children: [
            // Background glow orbs
            const _GlowOrb(
              color: VittaloColors.primary,
              top: -80,
              left: -60,
              size: 300,
            ),
            const _GlowOrb(
              color: VittaloColors.secondary,
              bottom: -100,
              right: -80,
              size: 280,
            ),
            _GlowOrb(
              color: VittaloColors.gold,
              top: MediaQuery.of(context).size.height * 0.4,
              right: -40,
              size: 180,
            ),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo mark
                  _LogoMark()
                      .animate()
                      .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 28),

                  // App name
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: VittaloColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                        ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut),

                  const SizedBox(height: 10),

                  // Tagline
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        VittaloColors.primaryGradient.createShader(bounds),
                    child: Text(
                      AppConstants.appTagline,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                    ),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.4, end: 0, duration: 500.ms),
                ],
              ),
            ),

            // Bottom loading indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: VittaloColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation(VittaloColors.primary),
                    ),
                  )
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 14),
                  Text(
                    'Loading models…',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: VittaloColors.textDisabled,
                          letterSpacing: 0.8,
                        ),
                  )
                      .animate(delay: 700.ms)
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logo Mark ────────────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: VittaloColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: VittaloColors.primary.withValues(alpha: 0.45),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '₹',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ─── Glow Orb ─────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  const _GlowOrb({
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
