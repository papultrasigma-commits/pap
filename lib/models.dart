
// Local models (easy to swap to DB later)

class UserProfile {
  final String nickname; // display
  final String ign; // in-game name
  final String passwordHash; // local auth only (for now)
  final String role; // Duelista/Iniciador/Sentinela/Controlador
  final List<String> mains; // agents
  final String valoTrackerUrl;
  final String? avatarBase64; // later

  const UserProfile({
    required this.nickname,
    required this.ign,
    required this.passwordHash,
    required this.role,
    required this.mains,
    required this.valoTrackerUrl,
    this.avatarBase64,
  });

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "ign": ign,
        "passwordHash": passwordHash,
        "role": role,
        "mains": mains,
        "valoTrackerUrl": valoTrackerUrl,
        "avatarBase64": avatarBase64,
      };

  static UserProfile fromJson(Map<String, dynamic> j) => UserProfile(
        nickname: j["nickname"],
        ign: j["ign"],
        passwordHash: j["passwordHash"],
        role: j["role"],
        mains: List<String>.from(j["mains"] ?? const []),
        valoTrackerUrl: j["valoTrackerUrl"] ?? "https://tracker.gg/valorant",
        avatarBase64: j["avatarBase64"],
      );

  UserProfile copyWith({
    String? role,
    List<String>? mains,
    bool? looking, // ignored here; stored in AppStore
    String? avatarBase64,
    String? valoTrackerUrl,
  }) {
    return UserProfile(
      nickname: nickname,
      ign: ign,
      passwordHash: passwordHash,
      role: role ?? this.role,
      mains: mains ?? this.mains,
      valoTrackerUrl: valoTrackerUrl ?? this.valoTrackerUrl,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
    );
  }
}

class Team {
  final String id;
  final String name;
  final List<String> members; // display names

  const Team({required this.id, required this.name, required this.members});

  Map<String, dynamic> toJson() => {"id": id, "name": name, "members": members};

  static Team fromJson(Map<String, dynamic> json) => Team(
        id: json["id"],
        name: json["name"],
        members: List<String>.from(json["members"] ?? const []),
      );
}

class JoinRequest {
  final String id;
  final String teamId;
  final String fromIgn;
  final String message;
  final int createdAtMs;

  const JoinRequest({
    required this.id,
    required this.teamId,
    required this.fromIgn,
    required this.message,
    required this.createdAtMs,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "teamId": teamId,
        "fromIgn": fromIgn,
        "message": message,
        "createdAtMs": createdAtMs,
      };

  static JoinRequest fromJson(Map<String, dynamic> j) => JoinRequest(
        id: j["id"],
        teamId: j["teamId"],
        fromIgn: j["fromIgn"],
        message: j["message"],
        createdAtMs: j["createdAtMs"],
      );
}
