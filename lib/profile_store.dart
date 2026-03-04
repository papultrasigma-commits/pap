import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  String email;
  String username; // O teu nome único (ex: joao123)
  String nickname; // O nome de exibição (ex: João Inácio)
  String ign;
  String role;
  bool looking;
  List<String> mains;

  UserProfile({
    required this.email,
    required this.username,
    required this.nickname,
    required this.ign,
    required this.role,
    required this.looking,
    required this.mains,
  });
}

class ProfileStore {
  final _supabase = Supabase.instance.client;

  Future<UserProfile> loadForEmail(String email) async {
    final user = _supabase.auth.currentUser;
    final defaultProfile = UserProfile(email: email, username: '', nickname: '', ign: '', role: 'Duelista', looking: false, mains: []);
    
    if (user == null) return defaultProfile;

    try {
      final data = await _supabase.from('profiles').select().eq('id', user.id).maybeSingle();
      if (data != null) {
        return UserProfile(
          email: email,
          username: data['username'] ?? '',
          nickname: data['nickname'] ?? '',
          ign: data['ign'] ?? '',
          role: data['role'] ?? 'Duelista',
          looking: data['looking'] ?? false,
          mains: List<String>.from(data['mains'] ?? []),
        );
      }
    } catch (e) {
      print("Erro ao carregar perfil: $e");
    }
    return defaultProfile;
  }

  // Agora retorna uma String se houver erro (ex: Username já existe)
  Future<String?> save(UserProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return "Utilizador não encontrado.";

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'username': profile.username.isEmpty ? null : profile.username, // Se estiver vazio, grava como nulo
        'nickname': profile.nickname,
        'ign': profile.ign,
        'role': profile.role,
        'looking': profile.looking,
        'mains': profile.mains,
      });
      return null; // Sucesso!
    } on PostgrestException catch (e) {
      // Como na BD o username tem "UNIQUE", isto apanha o erro se alguém já tiver esse username
      if (e.message.contains("unique constraint") || e.message.contains("profiles_username_key")) {
        return "Este Username já está a ser utilizado!";
      }
      return "Erro ao guardar na base de dados.";
    } catch (e) {
      return "Erro desconhecido ao guardar.";
    }
  }
}