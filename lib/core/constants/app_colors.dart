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

  // ── Background image ──
  final String backgroundImage;

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
    required this.backgroundImage,
    required this.brightness,
  });

  /// Convenience accessor.
  static HarmonyColors of(BuildContext context) {
    return Theme.of(context).extension<HarmonyColors>()!;
  }

  // ── Blue dominant light theme ──
  static const shazamBlue = HarmonyColors(
    brightness: Brightness.light,
    scaffold: Color(0xFFF0F4FF),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF007DFF),
    primaryLight: Color(0xFF3B82F6),
    accent: Color(0xFF2563EB),
    accentAlt: Color(0xFF60A5FA),
    success: Color(0xFF059669),
    error: Color(0xFFDC2626),
    warning: Color(0xFFF59E0B),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textHint: Color(0xFF94A3B8),
    glassBorder: Color(0xFFBFDBFE),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF007DFF), Color(0xFF007DFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFFF0F4FF), Color(0xFFDBEAFE)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [Colors.white, Color(0xFFF0F4FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: LinearGradient(
      colors: [Color(0xFF059669), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dangerGradient: LinearGradient(
      colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    fingerColors: [
      Color(0xFFDC2626),
      Color(0xFFF59E0B),
      Color(0xFF059669),
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
    ],
    backgroundImage: 'assets/images/bg_light.png',
  );

  // ── Orange / Black theme (dark mode) ──
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
    backgroundImage: 'assets/images/bg_dark.png',
  );

  // ── Doodle theme — blue wallpaper with white doodles ──
  // Designed for bg_doodle.png: medium-blue background with white icon pattern.
  // Cards are semi-transparent dark blue glass; gold accents pop on blue.
  static const doodle = HarmonyColors(
    brightness: Brightness.dark,
    scaffold: Color(0xFF3D6898),
    surface: Color(0xCC2B4F7A),
    card: Color(0xCC1F3D64),
    primary: Color(0xFF1565C0),
    primaryLight: Color(0xFF42A5F5),
    accent: Color(0xFFFFD54F),
    accentAlt: Color(0xFFFFE082),
    success: Color(0xFF66BB6A),
    error: Color(0xFFEF5350),
    warning: Color(0xFFFFCA28),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFB8D4EC),
    textHint: Color(0xFF7AAAD0),
    glassBorder: Color(0xFF5889B5),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF4A7FB5), Color(0xFF2E5E8E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xCC2B4F7A), Color(0xCC1F3D64)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: LinearGradient(
      colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dangerGradient: LinearGradient(
      colors: [Color(0xFFEF5350), Color(0xFFE57373)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    fingerColors: [
      Color(0xFFEF5350),
      Color(0xFFFFCA28),
      Color(0xFF66BB6A),
      Color(0xFF42A5F5),
      Color(0xFFAB47BC),
    ],
    backgroundImage: 'assets/images/bg_doodle.png',
  );

  // ── Chalk theme — black chalkboard with white chalk doodles ──
  // Designed for bg_chalk.png: dark chalkboard background with chalk drawings.
  // Cards are semi-transparent dark glass; green chalkboard accent.
  static const chalk = HarmonyColors(
    brightness: Brightness.dark,
    scaffold: Color(0xFF141414),
    surface: Color(0xCC1E1E1E),
    card: Color(0xCC1A1A1A),
    primary: Color(0xFF43A047),
    primaryLight: Color(0xFF66BB6A),
    accent: Color(0xFFFFEE58),
    accentAlt: Color(0xFFFFF176),
    success: Color(0xFF69F0AE),
    error: Color(0xFFFF5252),
    warning: Color(0xFFFFD740),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFFAAAAAA),
    textHint: Color(0xFF6E6E6E),
    glassBorder: Color(0xFF363636),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF141414), Color(0xFF1A1A1A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xCC1E1E1E), Color(0xCC1A1A1A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGradient: LinearGradient(
      colors: [Color(0xFF69F0AE), Color(0xFFA5D6A7)],
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
      Color(0xFFFFEE58),
      Color(0xFF69F0AE),
      Color(0xFF42A5F5),
      Color(0xFFCE93D8),
    ],
    backgroundImage: 'assets/images/bg_chalk.png',
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
  doodle,
  chalk,
}
