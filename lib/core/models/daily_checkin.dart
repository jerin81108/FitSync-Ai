/// Mood options for morning check-in
enum MoodEmoji {
  great(5, '🔥', 'Great', 'Feeling energised and ready to conquer the day'),
  good(4, '⚡', 'Good', 'Positive vibes, solid physical baseline'),
  okay(3, '😌', 'Okay', 'Steady, nothing special but holding up fine'),
  low(2, '🥱', 'Low', 'Feeling drained, dragging through tasks'),
  exhausted(1, '😴', 'Exhausted', 'Running on fumes, brain and body need care');

  final int score;
  final String emoji;
  final String label;
  final String description;

  const MoodEmoji(this.score, this.emoji, this.label, this.description);

  static MoodEmoji fromScore(int score) {
    return MoodEmoji.values.firstWhere(
      (m) => m.score == score,
      orElse: () => MoodEmoji.okay,
    );
  }

  static MoodEmoji fromName(String name) {
    return MoodEmoji.values.firstWhere(
      (m) => m.name.toLowerCase() == name.toLowerCase(),
      orElse: () => MoodEmoji.okay,
    );
  }
}

/// Daily Morning Check-in data model
class DailyCheckin {
  final String id;
  final String userId;
  final DateTime date;
  final MoodEmoji mood;
  final int stressLevel; // 1 (Zen) to 5 (Overwhelmed)
  final double sleepHours; // e.g. 7.5
  final int sleepQuality; // 1 (Poor) to 5 (Deep/Refreshed)
  final int yesterdayWorkoutIntensity; // 0 (Rest) to 5 (Max effort)
  final bool isHeavyDay; // Manual user flag or auto-detected
  final int scheduleLoadRating; // 0 to 100
  final bool isExamDay;
  final String? cyclePhase; // 'menstrual', 'follicular', 'ovulatory', 'luteal'
  final bool hasActiveInjury;
  final String? notes;

  const DailyCheckin({
    required this.id,
    required this.userId,
    required this.date,
    this.mood = MoodEmoji.okay,
    this.stressLevel = 2,
    this.sleepHours = 7.5,
    this.sleepQuality = 4,
    this.yesterdayWorkoutIntensity = 2,
    this.isHeavyDay = false,
    this.scheduleLoadRating = 20,
    this.isExamDay = false,
    this.cyclePhase,
    this.hasActiveInjury = false,
    this.notes,
  });

  factory DailyCheckin.defaultToday({required String userId}) {
    final now = DateTime.now();
    return DailyCheckin(
      id: '${userId}_${now.year}_${now.month}_${now.day}',
      userId: userId,
      date: DateTime(now.year, now.month, now.day),
      mood: MoodEmoji.good,
      stressLevel: 2,
      sleepHours: 7.5,
      sleepQuality: 4,
      yesterdayWorkoutIntensity: 2,
      isHeavyDay: false,
      scheduleLoadRating: 25,
      isExamDay: false,
      hasActiveInjury: false,
    );
  }

  DailyCheckin copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MoodEmoji? mood,
    int? stressLevel,
    double? sleepHours,
    int? sleepQuality,
    int? yesterdayWorkoutIntensity,
    bool? isHeavyDay,
    int? scheduleLoadRating,
    bool? isExamDay,
    String? cyclePhase,
    bool? hasActiveInjury,
    String? notes,
  }) {
    return DailyCheckin(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      yesterdayWorkoutIntensity: yesterdayWorkoutIntensity ?? this.yesterdayWorkoutIntensity,
      isHeavyDay: isHeavyDay ?? this.isHeavyDay,
      scheduleLoadRating: scheduleLoadRating ?? this.scheduleLoadRating,
      isExamDay: isExamDay ?? this.isExamDay,
      cyclePhase: cyclePhase ?? this.cyclePhase,
      hasActiveInjury: hasActiveInjury ?? this.hasActiveInjury,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'checkin_date': date.toIso8601String().split('T').first,
    'mood_emoji': mood.name,
    'mood_score': mood.score,
    'stress_level': stressLevel,
    'sleep_hours': sleepHours,
    'sleep_quality': sleepQuality,
    'yesterday_workout_intensity': yesterdayWorkoutIntensity,
    'is_heavy_day': isHeavyDay,
    'schedule_load_rating': scheduleLoadRating,
    'is_exam_day': isExamDay,
    'cycle_phase': cyclePhase,
    'has_active_injury': hasActiveInjury,
    'notes': notes,
  };

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      date: DateTime.parse(json['checkin_date'] as String),
      mood: MoodEmoji.fromName(json['mood_emoji'] as String? ?? 'okay'),
      stressLevel: (json['stress_level'] as num?)?.toInt() ?? 2,
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 7.0,
      sleepQuality: (json['sleep_quality'] as num?)?.toInt() ?? 3,
      yesterdayWorkoutIntensity: (json['yesterday_workout_intensity'] as num?)?.toInt() ?? 2,
      isHeavyDay: json['is_heavy_day'] as bool? ?? false,
      scheduleLoadRating: (json['schedule_load_rating'] as num?)?.toInt() ?? 20,
      isExamDay: json['is_exam_day'] as bool? ?? false,
      cyclePhase: json['cycle_phase'] as String?,
      hasActiveInjury: json['has_active_injury'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}
