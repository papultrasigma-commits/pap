import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _kUsers = 'users_v1'; // map email -> passHash
  static const _kLoggedIn = 'logged_in_v1';
  static const _kCurrentEmail = 'current_email_v1';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  Future<String?> currentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCurrentEmail);
  }

  String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null || raw.isEmpty) return {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, jsonEncode(users));
  }

  Future<String?> register({required String email, required String password}) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty || password.isEmpty) return 'Preenche email e password.';
    final users = await _loadUsers();
    if (users.containsKey(e)) return 'Esta conta já existe.';
    users[e] = _hash(password);
    await _saveUsers(users);
    // auto login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kCurrentEmail, e);
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final e = email.trim().toLowerCase();
    final users = await _loadUsers();
    if (!users.containsKey(e)) return 'Conta não existe.';
    if (users[e] != _hash(password)) return 'Password errada.';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kCurrentEmail, e);
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
    // mantém email guardado se quiseres, mas vou limpar
    await prefs.remove(_kCurrentEmail);
  }
}
