
import 'dart:math';
import 'package:flutter/material.dart';

class TeamDetailsPage extends StatelessWidget {
  final String teamName;
  final List<String> players;

  const TeamDetailsPage({super.key, required this.teamName, required this.players});

  @override
  Widget build(BuildContext context) {
    final rnd = Random(teamName.hashCode);
    final maps = const ["Bind","Ascent","Haven","Split","Lotus","Sunset"];

    return Scaffold(
      appBar: AppBar(title: Text(teamName)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) {
          final map = maps[rnd.nextInt(maps.length)];
          final win = rnd.nextBool();
          final scoreA = 13;
          final scoreB = rnd.nextInt(13);
          final result = win ? "$scoreA-$scoreB" : "$scoreB-$scoreA";
          final agents = const ["Jett","Raze","Sova","Omen","Killjoy","Viper","Skye","Cypher","Phoenix","Reyna"];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mapa: $map • Resultado: $result",
                      style: TextStyle(fontWeight: FontWeight.bold, color: win ? Colors.green : Colors.red)),
                  const SizedBox(height: 8),
                  ...players.map((p) {
                    final k = rnd.nextInt(25);
                    final d = rnd.nextInt(20);
                    final a = rnd.nextInt(12);
                    final ag = agents[rnd.nextInt(agents.length)];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("$p — $ag • $k/$d/$a"),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
