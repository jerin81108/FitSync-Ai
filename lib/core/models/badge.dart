/// Badge representation for gentle, guilt-free gamification
class AppBadge {
  final String key;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AppBadge({
    required this.key,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AppBadge copyWith({
    String? key,
    String? title,
    String? description,
    String? iconEmoji,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AppBadge(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  static List<AppBadge> predefinedBadges() {
    return [
      const AppBadge(
        key: 'exam_warrior',
        title: 'Exam Warrior',
        description: 'Prioritized mental clarity and gentle movement during heavy exam days.',
        iconEmoji: '🎓',
      ),
      const AppBadge(
        key: 'showed_up_tired',
        title: 'Showed Up Tired',
        description: 'Honored your fatigue with a gentle 15-minute routine instead of burning out.',
        iconEmoji: '😴',
      ),
      const AppBadge(
        key: 'seven_day_flex',
        title: '7-Day Flex',
        description: 'Completed 7 consecutive days of adapted movement and intentional rest.',
        iconEmoji: '🌿',
      ),
      const AppBadge(
        key: 'zero_guilt_master',
        title: 'Zero Guilt Master',
        description: 'Logged an intentional rest day on a heavy day without breaking your streak.',
        iconEmoji: '🛡️',
      ),
      const AppBadge(
        key: 'first_step',
        title: 'First Step',
        description: 'Completed your first adapted workout session in FitSync AI.',
        iconEmoji: '🌱',
      ),
      const AppBadge(
        key: 'mindful_breather',
        title: 'Mindful Breather',
        description: 'Chose a 10-minute de-stress breathing routine when tension peaked.',
        iconEmoji: '🧘',
      ),
    ];
  }
}
