import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences prefs;
  ThemeMode _themeMode;

  ThemeProvider({required this.prefs}) : _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? 1] {
    // Default to system theme if no preference is set
  }

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}
