import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFFEA580C);    // Deep Orange
  static const secondary = Color(0xFFF59E0B);  // Amber
  static const accent = Color(0xFF2563EB);     // Steel Blue

  static const background = Color(0xFFFAFAF9);
  static const surface = Colors.white;
  static const card = Colors.white;

  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF57534E);

  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF22C55E);
}

/// Centralized semantic color tokens used for domain concepts.
/// All screens must reference these instead of raw `Colors.*` values so that
/// colors stay consistent and can be updated in one place.
class AppSemanticColors {
  AppSemanticColors._();

  // ── Broadcast priority ────────────────────────────────────────────────────
  static const priorityNormal    = Color(0xFF2563EB); // blue  (≈ cs.tertiary)
  static const priorityUrgent    = Color(0xFFF59E0B); // amber (≈ cs.secondary)
  static const priorityEmergency = Color(0xFFDC2626); // red   (= AppColors.error)

  // ── Broadcast / schedule state ────────────────────────────────────────────
  static const statePlaying = Color(0xFF2563EB);  // same as priorityNormal
  static const stateDone    = Color(0xFF22C55E);  // = AppColors.success
  static const stateStopped = Color(0xFFF59E0B);  // same as priorityUrgent
  static const statePending = Color(0xFF57534E);  // = AppColors.textSecondary

  // ── Device / zone status ──────────────────────────────────────────────────
  static const statusOnline  = Color(0xFF22C55E); // = AppColors.success
  static const statusOffline = Color(0xFFDC2626); // = AppColors.error

  // ── Audio clip categories ─────────────────────────────────────────────────
  static const categoryChimes        = Color(0xFF14B8A6); // teal
  static const categoryAnnouncements = Color(0xFF2563EB); // blue
  static const categoryGreetings     = Color(0xFF22C55E); // green
  static const categoryAlerts        = Color(0xFFDC2626); // red

  // ── User roles ────────────────────────────────────────────────────────────
  static const roleAdmin       = Color(0xFFEA580C); // = AppColors.primary
  static const roleBroadcaster = Color(0xFF2563EB); // blue
  static const roleViewer      = Color(0xFF14B8A6); // teal

  // ── Admin menu card accents (decorative — no semantic meaning) ────────────
  static const cardIntegrations = Color(0xFF9333EA); // purple
  static const cardAppearance   = Color(0xFF4F46E5); // indigo
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFEDD5),
      onPrimaryContainer: Color(0xFF431407),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF451A03),
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFDBEAFE),
      onTertiaryContainer: Color(0xFF1E3A8A),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF7F1D1D),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: Color(0xFFD6D3D1),
      outlineVariant: Color(0xFFE7E5E4),
      inverseSurface: Color(0xFF292524),
      onInverseSurface: Color(0xFFFAFAF9),
      inversePrimary: Color(0xFFFDBA74),
      surfaceTint: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: const NavigationBarThemeData(elevation: 0),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFB923C),
      onPrimary: Color(0xFF431407),
      primaryContainer: Color(0xFFC2410C),
      onPrimaryContainer: Color(0xFFFFEDD5),
      secondary: Color(0xFFFBBF24),
      onSecondary: Color(0xFF451A03),
      secondaryContainer: Color(0xFFB45309),
      onSecondaryContainer: Color(0xFFFEF3C7),
      tertiary: Color(0xFF60A5FA),
      onTertiary: Color(0xFF1E3A8A),
      tertiaryContainer: Color(0xFF1D4ED8),
      onTertiaryContainer: Color(0xFFDBEAFE),
      error: Color(0xFFF87171),
      onError: Color(0xFF7F1D1D),
      errorContainer: Color(0xFF991B1B),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: Color(0xFF1C1917),
      onSurface: Color(0xFFFAFAF9),
      onSurfaceVariant: Color(0xFFA8A29E),
      outline: Color(0xFF44403C),
      outlineVariant: Color(0xFF57534E),
      inverseSurface: Color(0xFFF5F5F4),
      onInverseSurface: Color(0xFF1C1917),
      inversePrimary: AppColors.primary,
      surfaceTint: Color(0xFFFB923C),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: const NavigationBarThemeData(elevation: 0),
  );
}
