import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Vittalo Design Tokens ────────────────────────────────────────────────────

class VittaloColors {
  VittaloColors._();

  // Brand palette
  static const Color background = Color(0xFF0A0B14);
  static const Color surface = Color(0xFF13141F);
  static const Color surfaceVariant = Color(0xFF1A1C2B);
  static const Color cardBorder = Color(0xFF252738);

  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryLight = Color(0xFF9B7FFF);
  static const Color primaryDark = Color(0xFF5B3ED6);
  static const Color primaryContainer = Color(0xFF1E1740);

  static const Color secondary = Color(0xFF00D4A0);
  static const Color secondaryLight = Color(0xFF33DDAE);
  static const Color secondaryContainer = Color(0xFF00261D);

  static const Color gold = Color(0xFFF5C842);
  static const Color goldContainer = Color(0xFF2A2200);

  static const Color error = Color(0xFFFF5757);
  static const Color errorContainer = Color(0xFF2A0000);

  static const Color success = Color(0xFF00D4A0);
  static const Color warning = Color(0xFFFFB74D);

  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF9898B0);
  static const Color textDisabled = Color(0xFF4A4A60);

  // Gradient stops
  static const Gradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0B14), Color(0xFF1A1040), Color(0xFF0A0B14)],
    stops: [0.0, 0.5, 1.0],
  );

  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFC), Color(0xFF5B3ED6)],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5C842), Color(0xFFE8A800)],
  );

  static const Gradient priceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1740), Color(0xFF0E1025)],
  );
}

// ─── App Theme ────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: VittaloColors.primary,
      onPrimary: Colors.white,
      primaryContainer: VittaloColors.primaryContainer,
      onPrimaryContainer: VittaloColors.primaryLight,
      secondary: VittaloColors.secondary,
      onSecondary: Colors.black,
      secondaryContainer: VittaloColors.secondaryContainer,
      onSecondaryContainer: VittaloColors.secondaryLight,
      tertiary: VittaloColors.gold,
      onTertiary: Colors.black,
      tertiaryContainer: VittaloColors.goldContainer,
      onTertiaryContainer: VittaloColors.gold,
      error: VittaloColors.error,
      onError: Colors.white,
      errorContainer: VittaloColors.errorContainer,
      onErrorContainer: VittaloColors.error,
      surface: VittaloColors.surface,
      onSurface: VittaloColors.textPrimary,
      surfaceContainerHighest: VittaloColors.surfaceVariant,
      onSurfaceVariant: VittaloColors.textSecondary,
      outline: VittaloColors.cardBorder,
      outlineVariant: Color(0xFF1E2030),
      shadow: Colors.black,
      scrim: Colors.black87,
      inverseSurface: Color(0xFFF0F0F8),
      onInverseSurface: Color(0xFF0A0B14),
      inversePrimary: VittaloColors.primaryDark,
    );

    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: VittaloColors.textPrimary,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: VittaloColors.textPrimary,
        letterSpacing: -1.0,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: VittaloColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: VittaloColors.textPrimary,
        letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: VittaloColors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: VittaloColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: VittaloColors.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: VittaloColors.textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: VittaloColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: VittaloColors.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: VittaloColors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: VittaloColors.textPrimary,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: VittaloColors.textSecondary,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: VittaloColors.textDisabled,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: VittaloColors.background,
      textTheme: textTheme,

      appBarTheme: AppBarThemeData(
        backgroundColor: VittaloColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: VittaloColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: VittaloColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: VittaloColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: VittaloColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VittaloColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VittaloColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VittaloColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VittaloColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VittaloColors.error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: GoogleFonts.inter(
          color: VittaloColors.textDisabled,
          fontSize: 14,
        ),
        prefixIconColor: VittaloColors.textSecondary,
        suffixIconColor: VittaloColors.textSecondary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VittaloColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VittaloColors.primary,
          side: const BorderSide(color: VittaloColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VittaloColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: textTheme.labelLarge,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: VittaloColors.primary,
        inactiveTrackColor: VittaloColors.surfaceVariant,
        thumbColor: Colors.white,
        overlayColor: VittaloColors.primary.withValues(alpha: 0.15),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return VittaloColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return VittaloColors.primary;
          return VittaloColors.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: VittaloColors.surfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: VittaloColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: const DividerThemeData(
        color: VittaloColors.cardBorder,
        thickness: 1,
        space: 0,
      ),

      iconTheme: const IconThemeData(color: VittaloColors.textSecondary, size: 22),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: VittaloColors.primary,
        linearTrackColor: VittaloColors.surfaceVariant,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
