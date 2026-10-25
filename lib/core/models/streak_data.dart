/// Streak status tracking No-Guilt Flex Streak principles
class StreakData {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;
  final int totalIntentionalRestDays;
  final DateTime? lastActivityDate;
  final int streakFreezesLeft;
  final List<DateTime> completedDaysThisWeek;

  const StreakData({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalActiveDays = 0,
    this.totalIntentionalRestDays = 0,
    this.lastActivityDate,
    this.streakFreezesLeft = 2,
    this.completedDaysThisWeek = const [],
  });

  factory StreakData.initial({required String userId}) {
    return StreakData(
      userId: userId,
      currentStreak: 1,
      longestStreak: 1,
      totalActiveDays: 1,
      totalIntentionalRestDays: 0,
      lastActivityDate: DateTime.now(),
      streakFreezesLeft: 2,
      completedDaysThisWeek: [DateTime.now()],
    );
  }

  StreakData copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    int? totalActiveDays,
    int? totalIntentionalRestDays,
    DateTime? lastActivityDate,
    int? streakFreezesLeft,
    List<DateTime>? completedDaysThisWeek,
  }) {
    return StreakData(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalActiveDays: totalActiveDays ?? this.totalActiveDays,
      totalIntentionalRestDays: totalIntentionalRestDays ?? this.totalIntentionalRestDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakFreezesLeft: streakFreezesLeft ?? this.streakFreezesLeft,
      completedDaysThisWeek: completedDaysThisWeek ?? this.completedDaysThisWeek,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'total_active_days': totalActiveDays,
    'total_intentional_rest_days': totalIntentionalRestDays,
    'last_activity_date': lastActivityDate?.toIso8601String().split('T').first,
    'streak_freezes_left': streakFreezesLeft,
  };

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      userId: json['user_id'] as String? ?? '',
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      totalActiveDays: (json['total_active_days'] as num?)?.toInt() ?? 0,
      totalIntentionalRestDays: (json['total_intentional_rest_days'] as num?)?.toInt() ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      streakFreezesLeft: (json['streak_freezes_left'] as num?)?.toInt() ?? 2,
    );
  }
}
