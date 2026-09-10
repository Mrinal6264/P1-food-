import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? user;
  bool isLoading = true;

  Future<void> tryAutoLogin() async {
    final t = await ApiService.token;
    if (t == null) {
      isLoading = false;
      notifyListeners();
      return;
    }
    try {
      final res = await ApiService.get('account.php', auth: true);
      user = AppUser.fromJson(res['user']);
    } catch (_) {
      await ApiService.clearToken();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await ApiService.post('login.php', {'email': email, 'password': password});
    await ApiService.saveToken(res['token']);
    user = AppUser.fromJson(res['user']);
    notifyListeners();
  }

  Future<void> register(String name, String email, String phone, String password) async {
    final res = await ApiService.post('register.php', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
    await ApiService.saveToken(res['token']);
    user = AppUser.fromJson(res['user']);
    notifyListeners();
  }

  Future<void> updateProfile(String name, String phone, String address) async {
    final res = await ApiService.post('account.php', {'name': name, 'phone': phone, 'address': address}, auth: true);
    user = AppUser.fromJson(res['user']);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await ApiService.post('logout.php', {}, auth: true);
    } catch (_) {}
    await ApiService.clearToken();
    user = null;
    notifyListeners();
  }

  bool get isLoggedIn => user != null;
}
