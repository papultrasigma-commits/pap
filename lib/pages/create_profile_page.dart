import 'package:flutter/material.dart';
import '../profile_store.dart';

class CreateProfilePage extends StatefulWidget {
  final String email;
  final VoidCallback onProfileCreated;

  const CreateProfilePage({
    super.key,
    required this.email,
    required this.onProfileCreated,
  });

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _nicknameController = TextEditingController();
  final _ignController = TextEditingController();
  String _selectedRole = 'Duelista';
  bool _isLooking = false;
  final List<String> _selectedMains = [];
  bool _isLoading = false;

  final _roles = const ['Duelista', 'Iniciador', 'Sentinela', 'Controlador'];
  final _agents = const [
    'Jett', 'Raze', 'Reyna', 'Phoenix', 'Yoru', 'Neon', 'Iso',
    'Sova', 'Skye', 'Fade', 'Breach', 'KAY/O', 'Gekko',
    'Killjoy', 'Cypher', 'Sage', 'Chamber', 'Deadlock', 'Vyse',
    'Brimstone', 'Omen', 'Viper', 'Astra', 'Harbor', 'Clove'
  ];

  Future<void> _submit() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O Nickname é obrigatório!"), backgroundColor: Color(0xFFE02424)));
      return;
    }

    setState(() => _isLoading = true);
    
    // AQUI ESTÁ A MAGIA: Adicionámos o username vazio (a pessoa pode editar depois no Perfil)
    final profile = UserProfile(
      email: widget.email,
      username: '', 
      nickname: _nicknameController.text.trim(),
      ign: _ignController.text.trim(),
      role: _selectedRole,
      looking: _isLooking,
      mains: _selectedMains,
    );

    final error = await ProfileStore().save(profile);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: const Color(0xFFE02424)));
      } else {
        widget.onProfileCreated(); // Sucesso, avança para a app!
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        title: const Text("Criar Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Bem-vindo!", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Para começares a usar a app, precisamos de alguns detalhes sobre o teu perfil de jogador.", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 32),

          _buildInputLabel("Nickname (Como queres ser chamado)"),
          const SizedBox(height: 8),
          TextField(controller: _nicknameController, style: const TextStyle(color: Colors.white), decoration: _buildInputDecoration(hintText: "Ex: Shadow", icon: Icons.person)),
          const SizedBox(height: 16),

          _buildInputLabel("In-Game Name (Valorant IGN#TAG)"),
          const SizedBox(height: 8),
          TextField(controller: _ignController, style: const TextStyle(color: Colors.white), decoration: _buildInputDecoration(hintText: "Ex: JogadorPro#EUW", icon: Icons.sports_esports)),
          const SizedBox(height: 24),

          _buildInputLabel("A tua Role Principal"),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white),
            decoration: _buildInputDecoration(hintText: "", icon: Icons.security),
            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _selectedRole = v ?? _selectedRole),
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            value: _isLooking,
            activeColor: const Color(0xFFE02424),
            activeTrackColor: const Color(0xFF4A0000),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: const Color(0xFF222222),
            onChanged: (v) => setState(() => _isLooking = v),
            title: const Text("Procuro Equipa (LFG)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE02424),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("CRIAR PERFIL →", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) => Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500));

  InputDecoration _buildInputDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText, hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: const Color(0xFF111111),
      prefixIcon: Icon(icon, color: Colors.grey[500]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE02424))),
    );
  }
}