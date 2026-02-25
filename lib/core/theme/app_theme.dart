import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData fromMode(HarmonyThemeMode mode) {
    final HarmonyColors colors;
    switch (mode) {
      case HarmonyThemeMode.shazamBlue:
        colors = HarmonyColors.shazamBlue;
      case HarmonyThemeMode.shazamOrange:
        colors = HarmonyColors.shazamOrange;
      case HarmonyThemeMode.doodle:
        colors = HarmonyColors.doodle;
      case HarmonyThemeMode.chalk:
        colors = HarmonyColors.chalk;
    }
    return _build(colors);
  }

  static ThemeData _build(HarmonyColors c) {
    final isDark = c.brightness == Brightness.dark;
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return ThemeData(
      brightness: c.brightness,
      scaffoldBackgroundColor: c.scaffold,
      primaryColor: c.primary,
      colorScheme: ColorScheme(
        brightness: c.brightness,
        primary: c.primary,
        secondary: c.accent,
        surface: c.surface,
        error: c.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: c.textPrimary,
        onError: Colors.white,
      ),
      fontFamily: 'Roboto',
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: overlayStyle,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      cardTheme: CardTheme(
        color: c.card,
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? Colors.transparent : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.glassBorder),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        hintStyle: TextStyle(color: c.textHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.glassBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.glassBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.card,
        contentTextStyle: TextStyle(color: c.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
