import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'language_provider.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  LanguageProvider? _languageProvider;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  void attachLanguageProvider(LanguageProvider lang) {
    _languageProvider = lang;
  }

  // App চালু হলে saved user check করো
  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name');
    final userPhone = prefs.getString('user_phone');
    final userEmail = prefs.getString('user_email');
    final userRole = prefs.getString('user_role');

    if (token != null && userId != null) {
      _currentUser = UserModel(
        id: userId,
        name: userName ?? '',
        phone: userPhone,
        email: userEmail,
        role: userRole ?? 'seeker',
        token: token,
      );
      _languageProvider?.onUserChanged(userId);
      notifyListeners();
    }
  }

  Future<bool> login(String phone, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.login(phone, password, role);
      if (result != null) {
        _currentUser = result;
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result.token ?? '');
        await prefs.setInt('user_id', result.id);
        await prefs.setString('user_name', result.name);
        await prefs.setString('user_phone', result.phone ?? '');
        await prefs.setString('user_email', result.email ?? '');
        await prefs.setString('user_role', result.role);
        
        await _languageProvider?.onUserChanged(result.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(
      String name, String phone, String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.register(name, phone, email, password, role);
      if (result != null) {
        _currentUser = result;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result.token ?? '');
        await prefs.setInt('user_id', result.id);
        await prefs.setString('user_name', result.name);
        await prefs.setString('user_phone', result.phone ?? '');
        await prefs.setString('user_email', result.email ?? '');
        await prefs.setString('user_role', result.role);

        await _languageProvider?.onUserChanged(result.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    // Do not wipe language preferences! Only remove session auth keys.
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_email');
    await prefs.remove('user_role');

    await _languageProvider?.onUserChanged(null);
    notifyListeners();
  }
}
