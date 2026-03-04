import 'package:flutter/material.dart';
import '../profile_store.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _store = ProfileStore();
  UserProfile? _p;

  final _roles = const ['Duelista','Iniciador','Sentinela','Controlador'];
  final _agents = const [
    'Jett','Raze','Reyna','Phoenix','Yoru','Neon','Iso',
    'Sova','Skye','Fade','Breach','KAY/O','Gekko',
    'Killjoy','Cypher','Sage','Chamber','Deadlock',
    'Brimstone','Omen','Viper','Astra','Harbor','Clove'
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
    await _store.save(_p!);
    
    // Confirmação de que gravou
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Perfil guardado com sucesso!", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFE02424), // Vermelho premium
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
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0D),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE02424)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D), // Fundo escuro
      appBar: AppBar(
        title: const Text("O Meu Perfil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Cartão de Identificação Superior
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222222)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF4A0000),
                  child: Text(
                    p.nickname.isNotEmpty ? p.nickname[0].toUpperCase() : "?",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF8888)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nickname.isNotEmpty ? p.nickname : "Sem Nickname", 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.ign.isNotEmpty ? p.ign : "Sem IGN configurado", 
                        style: const TextStyle(color: Colors.grey, fontSize: 14)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dropdown "Role"
          const Text("Role Principal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: p.role,
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF111111),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE02424))),
            ),
            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => p.role = v ?? p.role),
          ),
          const SizedBox(height: 20),

          // Switch "À procura de equipa"
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
            ),
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

          // Agentes (Mains)
          const Text("Agentes (Mains)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
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
                backgroundColor: const Color(0xFF111111),
                selectedColor: const Color(0xFFE02424).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: selected ? const Color(0xFFE02424) : const Color(0xFF333333)),
                ),
                labelStyle: TextStyle(
                  color: selected ? const Color(0xFFE02424) : Colors.grey[400],
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (s) => setState(() {
                  s ? p.mains.add(a) : p.mains.remove(a);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Botão Guardar
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE02424),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: const Color(0xFFE02424).withOpacity(0.5),
              ),
              child: const Text("GUARDAR PERFIL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}