import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Manages the active theme and exposes the corresponding ThemeData.
class ThemeProvider extends ChangeNotifier {
  HarmonyThemeMode _mode = HarmonyThemeMode.shazamBlue;

  HarmonyThemeMode get mode => _mode;

  ThemeData get themeData => AppTheme.fromMode(_mode);

  void setTheme(HarmonyThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    final values = HarmonyThemeMode.values;
    _mode = values[(_mode.index + 1) % values.length];
    notifyListeners();
  }
}
