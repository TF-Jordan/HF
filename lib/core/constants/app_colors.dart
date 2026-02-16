import 'package:flutter/material.dart';

/// All custom colors for Harmony, provided as a ThemeExtension.
///
/// Usage: `HarmonyColors.of(context).primary`
class HarmonyColors extends ThemeExtension<HarmonyColors> {
  // ── Backgrounds ──
  final Color scaffold;
  final Color surface;
  final Color card;

  // ── Primary palette ──
  final Color primary;
  final Color primaryLight;

  // ── Accent ──
  final Color accent;
  final Color accentAlt;

  // ── Semantic ──
  final Color success;
  final Color error;
  final Color warning;

  // ── Text ──
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // ── Glass / borders ──
  final Color glassBorder;

  // ── Gradients ──
  final LinearGradient primaryGradient;
  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final LinearGradient successGradient;
  final LinearGradient dangerGradient;

  // ── Finger colors for flex sensor display ──
  final List<Color> fingerColors;

  // ── Brightness ──
  final Brightness brightness;

  const HarmonyColors({
    required this.scaffold,
    required this.surface,
    required this.card,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.accentAlt,
    required this.success,
    required this.error,
    required this.warning,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.glassBorder,
    required this.primaryGradient,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.successGradient,
    required this.dangerGradient,
    required this.fingerColors,
    required this.brightness,
  });

  /// Convenience accessor.
  static HarmonyColors of(BuildContext context) {
    return Theme.of(context).extension<HarmonyColors>()!;
  }

  // ── Blue / White theme (Shazam classic) ──
  static const shazamBlue = HarmonyColors(
    brightness: Brightness.light,
    scaffold: Color(0xFFF0F4F8),
    surface: Colors.white,
    card: Colors.white,
    primary: Color(0xFF0088FE),
    primaryLight: Color(0xFF33A1FF),
    accent: Color(0xFF0055D4),
    accentAlt: Color(0xFF00C2FF),
    success: Color(0xFF00C853),
    error: Color(0xFFE53935),
    warning: Color(0xFFFFA726),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textHint: Color(0xFF9CA3AF),
    glassBorder: Color(0xFFE2E8F0),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0088FE), Color(0xFF00C2FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFF0F4F8), Color(0xFFE8EDF5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [Colors.white, Color(0xFFF8FAFC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: LinearGradient(
      colors: [Color(0xFF00C853), Color(0xFF00E676)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dangerGradient: LinearGradient(
      colors: [Color(0xFFE53935), Color(0xFFFF5252)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    fingerColors: [
      Color(0xFFE53935),
      Color(0xFFFFA726),
      Color(0xFF00C853),
      Color(0xFF0088FE),
      Color(0xFF7C4DFF),
    ],
  );

  // ── Orange / Black theme (Shazam concert mode) ──
  static const shazamOrange = HarmonyColors(
    brightness: Brightness.dark,
    scaffold: Color(0xFF0A0A0A),
    surface: Color(0xFF161616),
    card: Color(0xFF1C1C1C),
    primary: Color(0xFFFF6B00),
    primaryLight: Color(0xFFFF8A33),
    accent: Color(0xFFFF9500),
    accentAlt: Color(0xFFFFAB40),
    success: Color(0xFF00E676),
    error: Color(0xFFFF5252),
    warning: Color(0xFFFFD740),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFF9E9E9E),
    textHint: Color(0xFF616161),
    glassBorder: Color(0xFF2A2A2A),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF0A0A0A), Color(0xFF121212)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFF1C1C1C), Color(0xFF161616)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: LinearGradient(
      colors: [Color(0xFF00E676), Color(0xFF69F0AE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dangerGradient: LinearGradient(
      colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    fingerColors: [
      Color(0xFFFF5252),
      Color(0xFFFFD740),
      Color(0xFF00E676),
      Color(0xFFFF6B00),
      Color(0xFFE040FB),
    ],
  );

  static const List<String> fingerNames = [
    'Pouce',
    'Index',
    'Majeur',
    'Annulaire',
    'Auriculaire',
  ];

  @override
  HarmonyColors copyWith() => this;

  @override
  HarmonyColors lerp(covariant ThemeExtension<HarmonyColors>? other, double t) {
    if (other is! HarmonyColors) return this;
    return t < 0.5 ? this : other;
  }
}

/// Theme identifier enum.
enum HarmonyThemeMode {
  shazamBlue,
  shazamOrange,
}
