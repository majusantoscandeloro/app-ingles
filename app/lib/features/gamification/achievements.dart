import '../../shared/models/user_profile.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool Function(UserProfile profile) isUnlocked;
}

final List<Achievement> kAchievements = [
  Achievement(
    id: 'first_lesson',
    emoji: '🏆',
    title: 'Primeira aula',
    description: 'Complete sua primeira aula',
    isUnlocked: (p) => p.lessonsCompleted >= 1,
  ),
  Achievement(
    id: 'perfect_lesson',
    emoji: '💎',
    title: 'Perfeição',
    description: 'Complete uma aula sem erros',
    isUnlocked: (p) => p.perfectLessons >= 1,
  ),
  Achievement(
    id: 'streak_7',
    emoji: '🔥',
    title: 'Uma semana',
    description: 'Estude durante 7 dias seguidos',
    isUnlocked: (p) => p.longestStreak >= 7,
  ),
  Achievement(
    id: 'good_listener',
    emoji: '🎧',
    title: 'Bom ouvinte',
    description: 'Complete 20 exercícios de áudio',
    isUnlocked: (p) => p.listenCompleted >= 20,
  ),
  Achievement(
    id: 'speaker',
    emoji: '🎤',
    title: 'Falante',
    description: 'Complete 20 exercícios de fala',
    isUnlocked: (p) => p.speakCompleted >= 20,
  ),
  Achievement(
    id: 'xp_1000',
    emoji: '⭐',
    title: 'Mil XP',
    description: 'Acumule 1.000 XP',
    isUnlocked: (p) => p.xp >= 1000,
  ),
];
