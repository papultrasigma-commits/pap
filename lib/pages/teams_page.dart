import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _myTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Vai buscar todas as equipas onde este utilizador é membro!
      // Usamos o poder do Supabase para juntar a tabela team_members com a tabela teams
      final response = await _supabase
          .from('team_members')
          .select('role, teams(id, name, color_hex)')
          .eq('user_id', user.id);
      
      setState(() {
        _myTeams = response;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao buscar equipas: $e");
      setState(() => _isLoading = false);
    }
  }

  // Função para converter o HEX que vem da BD numa Color do Flutter
  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF333333); // Cinza por defeito
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Adiciona opacidade a 100%
    return Color(int.tryParse('0x$hex') ?? 0xFF333333);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        title: const Text("As Minhas Equipas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE02424)))
          : _myTeams.isEmpty
              ? _buildEmptyState()
              : _buildTeamsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // No futuro, podes abrir aqui um ecrã para criar ou juntar a equipa!
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A criação de equipas está na App do PC!")));
        },
        backgroundColor: const Color(0xFFE02424),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text("Não pertences a nenhuma equipa.", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Cria uma equipa no PC ou pede\npara te convidarem!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTeamsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _myTeams.length,
      itemBuilder: (context, index) {
        final memberData = _myTeams[index];
        final team = memberData['teams']; // Os dados da equipa
        final myRole = memberData['role']; // Se sou 'owner' ou 'member'

        final teamColor = _parseColor(team['color_hex']);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: teamColor.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: teamColor.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 4)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: teamColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.shield, color: teamColor, size: 28),
            ),
            title: Text(team['name'] ?? 'Equipa Desconhecida', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(myRole == 'owner' ? Icons.star : Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(myRole == 'owner' ? 'Líder / Owner' : 'Membro', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              // Futuro: Abrir detalhes da equipa!
            },
          ),
        );
      },
    );
  }
}