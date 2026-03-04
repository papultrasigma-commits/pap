import 'package:flutter/material.dart';
import '../profile_store.dart';
import '../auth_service.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _store = ProfileStore();
  UserProfile? _p;
  bool _isLoading = false;

  final _roles = const ['Duelista', 'Iniciador', 'Sentinela', 'Controlador'];
  final _agents = const [
    'Jett', 'Raze', 'Reyna', 'Phoenix', 'Yoru', 'Neon', 'Iso',
    'Sova', 'Skye', 'Fade', 'Breach', 'KAY/O', 'Gekko',
    'Killjoy', 'Cypher', 'Sage', 'Chamber', 'Deadlock', 'Vyse',
    'Brimstone', 'Omen', 'Viper', 'Astra', 'Harbor', 'Clove'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _store.loadForEmail(widget.email);
    setState(() => _p = p);
  }

  Future<void> _save() async {
    if (_p == null) return;
    setState(() => _isLoading = true);
    
    final error = await _store.save(_p!);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? "Perfil atualizado com sucesso!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: error == null ? Colors.green[800] : const Color(0xFFE02424),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    if (p == null) {
      return const Scaffold(backgroundColor: Color(0xFF0B0B0D), body: Center(child: CircularProgressIndicator(color: Color(0xFFE02424))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        title: const Text("O Meu Perfil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              await AuthService().logout();
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          // CABEÇALHO DO PERFIL PREMIUM
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2A0808), Color(0xFF111111)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE02424).withOpacity(0.3)),
              boxShadow: [BoxShadow(color: const Color(0xFFE02424).withOpacity(0.1), blurRadius: 20, spreadRadius: 2)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFE02424),
                  child: Text(
                    p.nickname.isNotEmpty ? p.nickname[0].toUpperCase() : (p.username.isNotEmpty ? p.username[0].toUpperCase() : "?"),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nickname.isEmpty ? "Novo Jogador" : p.nickname, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(p.username.isEmpty ? "@username" : "@${p.username}", style: const TextStyle(color: Color(0xFFFF8888), fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(p.ign.isEmpty ? "Sem IGN" : "🎮 ${p.ign}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // SECÇÃO DE DADOS PESSOAIS
          const Text("DADOS DA CONTA", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          
          _buildTextField(label: "E-mail (Não editável)", initialValue: p.email, icon: Icons.email, isReadOnly: true),
          const SizedBox(height: 16),
          _buildTextField(label: "Username (Único)", initialValue: p.username, icon: Icons.alternate_email, onChanged: (v) => p.username = v),
          const SizedBox(height: 16),
          _buildTextField(label: "Nickname (Nome de exibição)", initialValue: p.nickname, icon: Icons.badge, onChanged: (v) => p.nickname = v),
          const SizedBox(height: 16),
          _buildTextField(label: "IGN (In-Game Name #TAG)", initialValue: p.ign, icon: Icons.sports_esports, onChanged: (v) => p.ign = v),
          const SizedBox(height: 32),

          // SECÇÃO DE JOGO
          const Text("PREFERÊNCIAS DE JOGO", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: p.role,
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: "Role Principal",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.security, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF111111),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE02424))),
            ),
            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => p.role = v ?? p.role),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              value: p.looking,
              activeColor: const Color(0xFFE02424),
              activeTrackColor: const Color(0xFF4A0000),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: const Color(0xFF222222),
              onChanged: (v) => setState(() => p.looking = v),
              title: const Text("À procura de equipa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              secondary: Icon(Icons.search, color: p.looking ? const Color(0xFFE02424) : Colors.grey),
            ),
          ),
          const SizedBox(height: 24),

          const Text("AGENTES MAINS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _agents.map((a) {
              final selected = p.mains.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                showCheckmark: false,
                backgroundColor: const Color(0xFF1A1A1A),
                selectedColor: const Color(0xFFE02424).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: selected ? const Color(0xFFE02424) : Colors.transparent),
                ),
                labelStyle: TextStyle(color: selected ? const Color(0xFFFF8888) : Colors.grey[400], fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                onSelected: (s) => setState(() { s ? p.mains.add(a) : p.mains.remove(a); }),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),

          // BOTÃO GRAVAR
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE02424),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: const Color(0xFFE02424).withOpacity(0.5),
              ),
              child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("GUARDAR ALTERAÇÕES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper para desenhar os inputs de texto bonitos
  Widget _buildTextField({required String label, required String initialValue, required IconData icon, bool isReadOnly = false, Function(String)? onChanged}) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: isReadOnly,
      onChanged: onChanged,
      style: TextStyle(color: isReadOnly ? Colors.grey[600] : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: isReadOnly ? Icon(Icons.lock_outline, color: Colors.grey[800], size: 18) : null,
        filled: true,
        fillColor: const Color(0xFF111111),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE02424))),
      ),
    );
  }
}