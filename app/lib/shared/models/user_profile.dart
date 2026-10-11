import 'model_utils.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.xp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDay,
    this.hearts = 5,
    this.heartsUpdatedAt,
    this.lessonsCompleted = 0,
    this.perfectLessons = 0,
    this.listenCompleted = 0,
    this.speakCompleted = 0,
    this.achievements = const [],
    this.startingLevel,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final int xp;
  final int currentStreak;
  final int longestStreak;

  /// Dia local (`yyyy-MM-dd`) do último estudo; base do cálculo de streak.
  final String? lastStudyDay;
  final int hearts;

  /// Âncora da recarga de corações: a partir dela conta-se o tempo de recarga.
  final DateTime? heartsUpdatedAt;

  /// Lições distintas concluídas (repetições não contam).
  final int lessonsCompleted;
  final int perfectLessons;
  final int listenCompleted;
  final int speakCompleted;
  final List<String> achievements;
  final String? startingLevel;
  final DateTime? createdAt;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) => UserProfile(
        uid: uid,
        name: (map['name'] ?? '') as String,
        email: (map['email'] ?? '') as String,
        xp: parseInt(map['xp']),
        currentStreak: parseInt(map['currentStreak']),
        longestStreak: parseInt(map['longestStreak']),
        lastStudyDay: map['lastStudyDay'] as String?,
        hearts: parseInt(map['hearts'], 5),
        heartsUpdatedAt: parseDate(map['heartsUpdatedAt']),
        lessonsCompleted: parseInt(map['lessonsCompleted']),
        perfectLessons: parseInt(map['perfectLessons']),
        listenCompleted: parseInt(map['listenCompleted']),
        speakCompleted: parseInt(map['speakCompleted']),
        achievements: parseStringList(map['achievements']),
        startingLevel: map['startingLevel'] as String?,
        createdAt: parseDate(map['createdAt']),
      );

  /// Não inclui `createdAt` nem `role`: são definidos na criação/servidor.
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'xp': xp,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastStudyDay': lastStudyDay,
        'hearts': hearts,
        'heartsUpdatedAt': heartsUpdatedAt,
        'lessonsCompleted': lessonsCompleted,
        'perfectLessons': perfectLessons,
        'listenCompleted': listenCompleted,
        'speakCompleted': speakCompleted,
        'achievements': achievements,
        'startingLevel': startingLevel,
      };

  UserProfile copyWith({
    String? name,
    int? xp,
    int? currentStreak,
    int? longestStreak,
    String? lastStudyDay,
    int? hearts,
    DateTime? heartsUpdatedAt,
    int? lessonsCompleted,
    int? perfectLessons,
    int? listenCompleted,
    int? speakCompleted,
    List<String>? achievements,
    String? startingLevel,
  }) =>
      UserProfile(
        uid: uid,
        name: name ?? this.name,
        email: email,
        xp: xp ?? this.xp,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastStudyDay: lastStudyDay ?? this.lastStudyDay,
        hearts: hearts ?? this.hearts,
        heartsUpdatedAt: heartsUpdatedAt ?? this.heartsUpdatedAt,
        lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
        perfectLessons: perfectLessons ?? this.perfectLessons,
        listenCompleted: listenCompleted ?? this.listenCompleted,
        speakCompleted: speakCompleted ?? this.speakCompleted,
        achievements: achievements ?? this.achievements,
        startingLevel: startingLevel ?? this.startingLevel,
        createdAt: createdAt,
      );
}
