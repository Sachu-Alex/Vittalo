import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vittalo/features/category_selection/domain/models/category_model.dart';
import 'package:vittalo/features/category_selection/presentation/screens/category_selection_screen.dart';
import 'package:vittalo/features/image_upload/presentation/screens/image_upload_screen.dart';
import 'package:vittalo/features/price_estimator/presentation/screens/input_wizard_screen.dart';
import 'package:vittalo/features/price_estimator/presentation/screens/result_screen.dart';
import 'package:vittalo/features/price_estimator/domain/entities/price_result.dart';
import 'package:vittalo/features/splash/presentation/splash_screen.dart';

// ─── Route Names ─────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String categorySelection = '/category';
  static const String imageUpload = '/image-upload';
  static const String inputWizard = '/input-wizard';
  static const String result = '/result';
}

// ─── App Router ───────────────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.categorySelection,
      name: 'category',
      builder: (context, state) => const CategorySelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.imageUpload,
      name: 'imageUpload',
      builder: (context, state) {
        final category = state.extra as CategoryModel;
        return ImageUploadScreen(category: category);
      },
    ),
    GoRoute(
      path: AppRoutes.inputWizard,
      name: 'inputWizard',
      builder: (context, state) {
        final args = state.extra as InputWizardArgs;
        return InputWizardScreen(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.result,
      name: 'result',
      builder: (context, state) {
        final result = state.extra as PriceResult;
        return ResultScreen(result: result);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);
