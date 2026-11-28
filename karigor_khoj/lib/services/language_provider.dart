import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _defaultLanguage = 'en';
  static const String _prefCurrentLang = 'app_language';
  static const String _prefUserPrefix = 'user_language_';

  String _currentLanguage = _defaultLanguage;
  int? _activeUserId;
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;
  bool get isBengali => _currentLanguage == 'bn';
  bool get isEnglish => _currentLanguage == 'en';
  Locale get currentLocale => Locale(_currentLanguage);
  int? get activeUserId => _activeUserId;
  bool get isInitialized => _isInitialized;

  LanguageProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    // User requested: "initially English language"
    // If not set yet, defaults strictly to 'en'
    final savedLang = prefs.getString(_prefCurrentLang);
    if (savedLang == 'bn' || savedLang == 'en') {
      _currentLanguage = savedLang;
    } else {
      _currentLanguage = _defaultLanguage;
      await prefs.setString(_prefCurrentLang, _defaultLanguage);
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Called whenever user logs in, registers, or saved user is restored from disk.
  Future<void> onUserChanged(int? userId) async {
    _activeUserId = userId;
    final prefs = await SharedPreferences.getInstance();

    if (userId != null) {
      final userKey = '$_prefUserPrefix$userId';
      final savedUserLang = prefs.getString(userKey);

      if (savedUserLang == 'en' || savedUserLang == 'bn') {
        // Restore this specific user's saved language preference
        _currentLanguage = savedUserLang;
        await prefs.setString(_prefCurrentLang, _currentLanguage);
      } else {
        // This user doesn't have a saved preference yet, associate current language
        await prefs.setString(userKey, _currentLanguage);
      }
    } else {
      // User logged out or guest; check guest/global preference
      final savedGuestLang = prefs.getString('${_prefUserPrefix}guest') ?? _currentLanguage;
      _currentLanguage = savedGuestLang;
      await prefs.setString(_prefCurrentLang, _currentLanguage);
    }

    notifyListeners();
  }

  /// Sets language ('en' or 'bn') and persists for the active user (or guest).
  Future<void> setLanguage(String langCode) async {
    if (langCode != 'en' && langCode != 'bn') return;
    if (_currentLanguage == langCode) return;

    _currentLanguage = langCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCurrentLang, langCode);

    if (_activeUserId != null) {
      await prefs.setString('$_prefUserPrefix$_activeUserId', langCode);
    } else {
      await prefs.setString('${_prefUserPrefix}guest', langCode);
    }
  }

  /// Toggles between English and Bangla
  Future<void> toggleLanguage() async {
    final nextLang = _currentLanguage == 'en' ? 'bn' : 'en';
    await setLanguage(nextLang);
  }

  /// Shorthand to translate a key
  String t(String key) {
    return AppTranslations.get(key, _currentLanguage);
  }

  /// Shorthand to translate a category name
  String trCategory(String category) {
    return AppTranslations.translateCategory(category, _currentLanguage);
  }

  /// Shorthand to translate a status
  String trStatus(String status) {
    return AppTranslations.translateStatus(status, _currentLanguage);
  }
}
