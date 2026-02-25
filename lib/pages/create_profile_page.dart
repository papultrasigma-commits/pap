import 'package:flutter/material.dart';
import '../profile_store.dart';

class CreateProfilePage extends StatefulWidget {
  final String email;
  final Future<void> Function() onCreated;
  const CreateProfilePage({super.key, required this.email, required this.onCreated});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _store = ProfileStore();
  final _nickname = TextEditingController();
  final _ign = TextEditingController();

  final _roles = const ['Duelista','Iniciador','Sentinela','Controlador'];
  String _role = 'Duelista';

  @override
  void dispose() {
    _nickname.dispose();
    _ign.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_nickname.text.trim().isEmpty || _ign.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preenche Nickname e IGN.")),
      );
      return;
    }

    final profile = UserProfile(
      email: widget.email,
      nickname: _nickname.text.trim(),
      ign: _ign.text.trim(),
      role: _role,
      mains: const [],
      looking: true,
    );

    await _store.save(profile);
    await widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Perfil")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Conta: ${widget.email}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: _nickname,
            decoration: const InputDecoration(labelText: "Nickname"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ign,
            decoration: const InputDecoration(labelText: "Nick In-Game (IGN)"),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(labelText: "Role"),
            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _role = v ?? 'Duelista'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _create,
              child: const Text("CRIAR PERFIL"),
            ),
          ),
        ],
      ),
    );
  }
}
