import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences preferences;
  static const String _themeKey = 'is_dark_mode';
  ThemeCubit(this.preferences) : super(_loadTheme(preferences));

  static ThemeMode _loadTheme(SharedPreferences preferences) {
    final isDark = preferences.getBool(_themeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) async {
    await preferences.setBool(_themeKey, isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
