import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences preferences;
  static const String _localeKey = "app_locale";

  LocaleCubit(this.preferences) : super(_loadLocale(preferences));

  static Locale _loadLocale(SharedPreferences preferences) {
    final langCode = preferences.getString(_localeKey) ?? 'ru';
    return Locale(langCode);
  }

  void setLocale(String langCode) async {
    await preferences.setString(_localeKey, langCode);
    emit(Locale(langCode));
  }
}
