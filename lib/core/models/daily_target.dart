/// Daily Target model adapted dynamically from Readiness Score
class DailyTarget {
  final String id;
  final String userId;
  final DateTime date;
  final int baseSteps;
  final int adaptedSteps;
  final int baseActiveMinutes;
  final int adaptedActiveMinutes;
  final int scalingPercentage; // e.g. 30, 65, 100, 115
  final String suggestedWorkoutId;
  final String suggestedWorkoutTitle;
  final int userManualOverride; // -1: easier, 0: auto/none, 1: harder
  final bool isPushDay;
  final bool isIntentionalRestDay;
  final bool isCompleted;
  final int stepsAchieved;
  final int activeMinutesAchieved;

  const DailyTarget({
    required this.id,
    required this.userId,
    required this.date,
    this.baseSteps = 8000,
    required this.adaptedSteps,
    this.baseActiveMinutes = 30,
    required this.adaptedActiveMinutes,
    required this.scalingPercentage,
    required this.suggestedWorkoutId,
    required this.suggestedWorkoutTitle,
    this.userManualOverride = 0,
    this.isPushDay = false,
    this.isIntentionalRestDay = false,
    this.isCompleted = false,
    this.stepsAchieved = 0,
    this.activeMinutesAchieved = 0,
  });

  DailyTarget copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? baseSteps,
    int? adaptedSteps,
    int? baseActiveMinutes,
    int? adaptedActiveMinutes,
    int? scalingPercentage,
    String? suggestedWorkoutId,
    String? suggestedWorkoutTitle,
    int? userManualOverride,
    bool? isPushDay,
    bool? isIntentionalRestDay,
    bool? isCompleted,
    int? stepsAchieved,
    int? activeMinutesAchieved,
  }) {
    return DailyTarget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      baseSteps: baseSteps ?? this.baseSteps,
      adaptedSteps: adaptedSteps ?? this.adaptedSteps,
      baseActiveMinutes: baseActiveMinutes ?? this.baseActiveMinutes,
      adaptedActiveMinutes: adaptedActiveMinutes ?? this.adaptedActiveMinutes,
      scalingPercentage: scalingPercentage ?? this.scalingPercentage,
      suggestedWorkoutId: suggestedWorkoutId ?? this.suggestedWorkoutId,
      suggestedWorkoutTitle: suggestedWorkoutTitle ?? this.suggestedWorkoutTitle,
      userManualOverride: userManualOverride ?? this.userManualOverride,
      isPushDay: isPushDay ?? this.isPushDay,
      isIntentionalRestDay: isIntentionalRestDay ?? this.isIntentionalRestDay,
      isCompleted: isCompleted ?? this.isCompleted,
      stepsAchieved: stepsAchieved ?? this.stepsAchieved,
      activeMinutesAchieved: activeMinutesAchieved ?? this.activeMinutesAchieved,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'target_date': date.toIso8601String().split('T').first,
    'base_steps': baseSteps,
    'adapted_steps': adaptedSteps,
    'base_active_minutes': baseActiveMinutes,
    'adapted_active_minutes': adaptedActiveMinutes,
    'scaling_percentage': scalingPercentage,
    'suggested_workout_id': suggestedWorkoutId,
    'suggested_workout_title': suggestedWorkoutTitle,
    'user_manual_override': userManualOverride,
    'is_push_day': isPushDay,
    'is_intentional_rest_day': isIntentionalRestDay,
    'is_completed': isCompleted,
    'steps_achieved': stepsAchieved,
    'active_minutes_achieved': activeMinutesAchieved,
  };

  factory DailyTarget.fromJson(Map<String, dynamic> json) {
    return DailyTarget(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      date: DateTime.parse(json['target_date'] as String),
      baseSteps: (json['base_steps'] as num?)?.toInt() ?? 8000,
      adaptedSteps: (json['adapted_steps'] as num?)?.toInt() ?? 8000,
      baseActiveMinutes: (json['base_active_minutes'] as num?)?.toInt() ?? 30,
      adaptedActiveMinutes: (json['adapted_active_minutes'] as num?)?.toInt() ?? 30,
      scalingPercentage: (json['scaling_percentage'] as num?)?.toInt() ?? 100,
      suggestedWorkoutId: json['suggested_workout_id'] as String? ?? 'quick_15_calm_mobility',
      suggestedWorkoutTitle: json['suggested_workout_title'] as String? ?? 'Quick 15 Mobility',
      userManualOverride: (json['user_manual_override'] as num?)?.toInt() ?? 0,
      isPushDay: json['is_push_day'] as bool? ?? false,
      isIntentionalRestDay: json['is_intentional_rest_day'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      stepsAchieved: (json['steps_achieved'] as num?)?.toInt() ?? 0,
      activeMinutesAchieved: (json['active_minutes_achieved'] as num?)?.toInt() ?? 0,
    );
  }
}
