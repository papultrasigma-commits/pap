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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil guardado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(p.nickname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text(p.ign),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: p.role,
            decoration: const InputDecoration(labelText: "Role"),
            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => p.role = v ?? p.role),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: p.looking,
            onChanged: (v) => setState(() => p.looking = v),
            title: const Text("À procura de equipa"),
          ),
          const SizedBox(height: 12),
          const Text("Mains", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _agents.map((a) {
              final selected = p.mains.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                onSelected: (s) => setState(() {
                  s ? p.mains.add(a) : p.mains.remove(a);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text("GUARDAR"),
            ),
          ),
        ],
      ),
    );
  }
}
