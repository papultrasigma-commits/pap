import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String email; // chave
  String nickname;
  String ign;
  String role; // Duelista/Iniciador/Sentinela/Controlador
  List<String> mains;
  bool looking;
  String? avatarBase64;

  UserProfile({
    required this.email,
    required this.nickname,
    required this.ign,
    required this.role,
    required this.mains,
    required this.looking,
    this.avatarBase64,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'nickname': nickname,
    'ign': ign,
    'role': role,
    'mains': mains,
    'looking': looking,
    'avatarBase64': avatarBase64,
  };

  static UserProfile fromJson(Map<String, dynamic> j) => UserProfile(
    email: j['email'],
    nickname: j['nickname'],
    ign: j['ign'],
    role: j['role'],
    mains: List<String>.from(j['mains'] ?? const []),
    looking: j['looking'] ?? false,
    avatarBase64: j['avatarBase64'],
  );
}

class ProfileStore {
  static const _kProfiles = 'profiles_by_email_v1'; // map email->profile json

  Future<UserProfile?> loadForEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfiles);
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final item = map[email];
    if (item == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(item));
  }

  Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfiles);
    final map = (raw == null || raw.isEmpty)
        ? <String, dynamic>{}
        : (jsonDecode(raw) as Map<String, dynamic>);
    map[profile.email] = profile.toJson();
    await prefs.setString(_kProfiles, jsonEncode(map));
  }
}
