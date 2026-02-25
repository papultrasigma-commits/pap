import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'profile_store.dart';
import 'main.dart';
import 'pages/create_profile_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  final _profiles = ProfileStore();

  bool? _loggedIn;
  String? _email;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logged = await _auth.isLoggedIn();
    String? email;
    UserProfile? profile;
    if (logged) {
      email = await _auth.currentEmail();
      if (email != null) {
        profile = await _profiles.loadForEmail(email);
      }
    }
    setState(() {
      _loggedIn = logged;
      _email = email;
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loggedIn == false) {
      return LoginPage(onDone: _load);
    }

    // logged in but no profile -> force create
    if (_email != null && _profile == null) {
      return CreateProfilePage(
        email: _email!,
        onCreated: () async {
          await _load();
        },
      );
    }

    return MainScreen(
      currentEmail: _email!,
      onLogout: () async {
        await _auth.logout();
        await _load();
      },
    );
  }
}
