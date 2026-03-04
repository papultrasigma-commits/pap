import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importação do Supabase

import 'auth_gate.dart';
import 'app_store.dart';

import 'pages/matches_page.dart';
import 'pages/teams_page.dart';
import 'pages/profile_page.dart';

final appStore = AppStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // INICIALIZAR O SUPABASE COM AS TUAS CHAVES REAIS!
  await Supabase.initialize(
    url: 'https://kkidrjsjkyzetowrydtt.supabase.co',
    anonKey: 'sb_publishable_YLac_kYcNaiM_Jb5vUXlsQ_RtwPa800', 
  );

  await appStore.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Equipa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        // Cores base do nosso design Premium
        scaffoldBackgroundColor: const Color(0xFF0B0B0D), // Fundo quase preto
        primaryColor: const Color(0xFFE02424), // Vermelho vibrante
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE02424),
          surface: Color(0xFF111111), // Cor dos cartões e menus
          background: Color(0xFF0B0B0D),
        ),
        fontFamily: 'Inter', // Fonte moderna (se adicionares ao projeto)
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String currentEmail;
  final Future<void> Function() onLogout;

  const MainScreen({super.key, required this.currentEmail, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // As tuas páginas atuais - AGORA CORRIGIDAS!
    final pages = <Widget>[
      const MatchesPage(),
      const TeamsPage(), // <-- AQUI ESTÁ A CORREÇÃO: Sem o 'store: appStore'
      ProfilePage(email: widget.currentEmail),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      // Barra de Navegação com estilo Premium Dark
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFF111111), // Cinza muito escuro
            indicatorColor: const Color(0xFFE02424).withOpacity(0.15), // Fundo do ícone selecionado
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(color: Color(0xFFE02424), fontWeight: FontWeight.bold, fontSize: 12);
              }
              return const TextStyle(color: Colors.grey, fontSize: 12);
            }),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(color: Color(0xFFE02424)); // Ícone vermelho quando selecionado
              }
              return const IconThemeData(color: Colors.grey); // Ícone cinza quando inativo
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Jogos',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: 'Equipa',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}