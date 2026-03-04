import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<bool> isLoggedIn() async {
    return _supabase.auth.currentSession != null;
  }

  Future<String?> currentEmail() async {
    return _supabase.auth.currentUser?.email;
  }

  // O Registo agora apenas envia o email com o código
  Future<String?> register({required String email, required String password}) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) return 'Preenche o e-mail e a palavra-passe.';
      
      await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return null; // Sucesso, o email foi enviado!
    } on AuthException catch (e) {
      return e.message; 
    } catch (e) {
      return 'Ocorreu um erro desconhecido ao registar.';
    }
  }

  // NOVA FUNÇÃO: Validar o código de 6 dígitos
  Future<String?> verifyCode({required String email, required String code}) async {
    try {
      await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email.trim(),
        token: code.trim(),
      );
      return null; // Sucesso! Conta verificada.
    } on AuthException catch (e) {
      return 'Código inválido ou expirado.';
    } catch (e) {
      return 'Erro ao verificar o código.';
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) return 'Preenche o e-mail e a palavra-passe.';

      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      // Se a conta não estiver verificada, ele dá erro aqui
      if (e.message.contains("Email not confirmed")) {
        return "Por favor, verifica o teu e-mail primeiro.";
      }
      return "E-mail ou palavra-passe incorretos."; 
    } catch (e) {
      return 'Ocorreu um erro ao iniciar sessão.';
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}