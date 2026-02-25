
import 'package:flutter/material.dart';
import '../app_store.dart';
import 'team_details_page.dart';

class TeamsPage extends StatelessWidget {
  final AppStore store;
  const TeamsPage({super.key, required this.store});

  Future<void> _askToJoin(BuildContext context, String teamId, String teamName) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pedir para entrar: $teamName"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: "Escreve uma frase (ex: sou main Sova, tenho bom comms...)",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Enviar")),
        ],
      ),
    );

    if (ok == true) {
      await store.requestToJoin(teamId: teamId, message: ctrl.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pedido enviado!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = store.hasProfile;
    final hasTeam = store.myTeamId != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Equipas")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: store.teams.map((t) {
          return Card(
            child: ListTile(
              title: Text(t.name),
              subtitle: Text(t.members.join(", ")),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TeamDetailsPage(teamName: t.name, players: t.members)),
              ),
              trailing: (!hasTeam && hasProfile)
                  ? TextButton(
                      onPressed: () => _askToJoin(context, t.id, t.name),
                      child: const Text("Pedir"),
                    )
                  : const Icon(Icons.chevron_right),
            ),
          );
        }).toList(),
      ),
    );
  }
}
