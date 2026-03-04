import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'login_page.dart';
import 'pages/create_profile_page.dart';
import 'profile_store.dart';
import 'main.dart'; // Para importar o MainScreen

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  final _store = ProfileStore();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userEmail;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);

    final loggedIn = await _auth.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
      return;
    }

    final email = await _auth.currentEmail();
    if (email == null) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
      return;
    }

    // Carregar o perfil para ver se já o criou
    final profile = await _store.loadForEmail(email);
    
    if (mounted) {
      setState(() {
        _isLoggedIn = true;
        _userEmail = email;
        // Se o nickname estiver vazio, significa que a pessoa ainda não criou o perfil
        _hasProfile = profile.nickname.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0D),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE02424))),
      );
    }

    if (!_isLoggedIn || _userEmail == null) {
      return LoginPage(
        onDone: _checkStatus,
      );
    }

    if (!_hasProfile) {
      return CreateProfilePage(
        email: _userEmail!,
        onProfileCreated: _checkStatus, // <--- O ERRO ESTAVA AQUI, AGORA ESTÁ CORRIGIDO!
      );
    }

    return MainScreen(
      currentEmail: _userEmail!,
      onLogout: () async {
        await _auth.logout();
        _checkStatus();
      },
    );
  }
}