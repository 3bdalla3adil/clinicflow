import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';

abstract class AppTheme {
  static ThemeData light() => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          background: AppColors.backgroundLight,
          surface: AppColors.surfaceLight,
          surfaceVariant: AppColors.surfaceVariantLight,
          outline: AppColors.outlineLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: AppColors.onSurfaceLight,
          onSurface: AppColors.onSurfaceLight,
          onSurfaceVariant: AppColors.onSurfaceVariantLight,
        ),
      );

  static ThemeData dark() => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primaryLight,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondaryLight,
          background: AppColors.backgroundDark,
          surface: AppColors.surfaceDark,
          surfaceVariant: AppColors.surfaceVariantDark,
          outline: AppColors.outlineDark,
          onPrimary: Colors.white,
          onBackground: AppColors.onSurfaceDark,
          onSurface: AppColors.onSurfaceDark,
        ),
      );

  static ThemeData _build(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: cs.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: AppTypography.textTheme.titleLarge
            ?.copyWith(color: cs.onSurface),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          side: BorderSide(color: cs.outline.withOpacity(0.3)),
        ),
        color: cs.surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceXXL,
            vertical: AppDimensions.spaceM,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          side: BorderSide(color: cs.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceXXL,
            vertical: AppDimensions.spaceM,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? cs.surfaceVariant.withOpacity(0.5)
            : cs.surfaceVariant.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceL,
          vertical: AppDimensions.spaceM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(color: cs.error),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppDimensions.bottomNavHeight,
        elevation: 0,
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle:
            MaterialStateProperty.all(AppTypography.textTheme.labelSmall),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outline.withOpacity(0.2),
        thickness: 1,
        space: 0,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXXL),
          ),
        ),
      ),
    );
  }
}
