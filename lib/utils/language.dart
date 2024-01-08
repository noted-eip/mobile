import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {
  static const String _kLanguageKey = 'selectedLanguage';

  static const Locale _defaultLanguage = Locale('fr', 'FRA');

  static const List<Locale> languages = [
    Locale('en', 'EN'),
    Locale('fr', 'FRA'),
  ];

  static const Map<String, Locale> _languageMap = {
    'en': Locale('en', 'EN'),
    'fr': Locale('fr', 'FRA'),
  };

  static const Map<String, String> languageNameMap = {
    'en': 'English',
    'fr': 'Français',
  };

  static const Map<String, String> languageFlagMap = {
    'en': '🇬🇧',
    'fr': '🇫🇷',
  };

  static Future<void> setLangue(BuildContext context, String langCode) async {
    context.setLocale(_languageMap[langCode]!);
    await saveLanguage(langCode);
  }

  static Future<void> saveLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguageKey, languageCode);
  }

  static Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? langue = prefs.getString(_kLanguageKey);

    if (langue == null) {
      return _defaultLanguage.languageCode;
    }
    return langue;
  }

  static Future<void> resetLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLanguageKey);
  }

  static Future<Locale> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? langue = prefs.getString(_kLanguageKey);

    if (langue == null) {
      return _defaultLanguage;
    }
    return _languageMap[langue] ?? _defaultLanguage;
  }
}
