
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStore extends ChangeNotifier {
  static const _kProfile = "user_profile_v2";
  static const _kLooking = "user_looking_v1";
  static const _kMyTeamId = "my_team_id_v1";
  static const _kTeams = "teams_v2";
  static const _kJoinReqs = "join_requests_v1";
  static const _kSeeded = "seeded_v2";

  final _rng = Random();

  UserProfile? profile;
  bool lookingForTeam = true;
  String? myTeamId;

  List<Team> teams = [];
  List<JoinRequest> joinRequests = [];

  String _id() => "${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(99999)}";

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // profile
    final rawProfile = prefs.getString(_kProfile);
    if (rawProfile != null) {
      profile = UserProfile.fromJson(jsonDecode(rawProfile));
    }

    lookingForTeam = prefs.getBool(_kLooking) ?? true;
    myTeamId = prefs.getString(_kMyTeamId);

    // teams
    final rawTeams = prefs.getString(_kTeams);
    if (rawTeams != null) {
      teams = (jsonDecode(rawTeams) as List).map((e) => Team.fromJson(e)).toList();
    }

    // join requests
    final rawReqs = prefs.getString(_kJoinReqs);
    if (rawReqs != null) {
      joinRequests = (jsonDecode(rawReqs) as List).map((e) => JoinRequest.fromJson(e)).toList();
    }

    // seed
    final seeded = prefs.getBool(_kSeeded) ?? false;
    if (!seeded || teams.isEmpty) {
      _seedTeams();
      await prefs.setBool(_kSeeded, true);
      await _saveTeams();
    }

    notifyListeners();
  }

  bool get hasProfile => profile != null;

  Team? get myTeam {
    if (myTeamId == null) return null;
    return teams.where((t) => t.id == myTeamId).cast<Team?>().firstWhere((e) => true, orElse: () => null);
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<void> createProfile({
    required String nickname,
    required String ign,
    required String password,
    required String valoTrackerUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    profile = UserProfile(
      nickname: nickname.trim(),
      ign: ign.trim(),
      passwordHash: hashPassword(password),
      role: "Duelista",
      mains: const [],
      valoTrackerUrl: valoTrackerUrl.trim().isEmpty ? "https://tracker.gg/valorant" : valoTrackerUrl.trim(),
    );

    await prefs.setString(_kProfile, jsonEncode(profile!.toJson()));
    notifyListeners();
  }

  Future<void> updateProfile({required String role, required List<String> mains, String? valoTrackerUrl}) async {
    if (profile == null) return;
    final prefs = await SharedPreferences.getInstance();
    profile = profile!.copyWith(role: role, mains: mains, valoTrackerUrl: valoTrackerUrl);
    await prefs.setString(_kProfile, jsonEncode(profile!.toJson()));
    notifyListeners();
  }

  Future<void> setLooking(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    lookingForTeam = v;
    await prefs.setBool(_kLooking, v);
    notifyListeners();
  }

  Future<void> requestToJoin({required String teamId, required String message}) async {
    if (profile == null) return;
    final prefs = await SharedPreferences.getInstance();
    final req = JoinRequest(
      id: _id(),
      teamId: teamId,
      fromIgn: profile!.ign,
      message: message.trim(),
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    joinRequests = [req, ...joinRequests];
    await prefs.setString(_kJoinReqs, jsonEncode(joinRequests.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  void _seedTeams() {
    teams = const [
      Team(id: "twk", name: "Os Twinks", members: ["Luna", "Mika", "Ravi", "Noah", "Eli"]),
      Team(id: "mcp", name: "Os McLovers no Prime", members: ["batata", "kiko", "maciera", "santi", "pedro"]),
      Team(id: "nmc", name: "Os New McLovers", members: ["batata", "kiko", "ruben", "bolinha", "formiga"]),
    ];
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTeams, jsonEncode(teams.map((e) => e.toJson()).toList()));
  }
}
