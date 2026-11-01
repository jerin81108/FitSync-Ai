/// Anti-Robot Adaptive Challenge & Progression Model
/// Ensures users are never treated like robots when moving between levels.
/// If Level 3 was hard ("Kashtam-ah irundhuchu"), an equivalent consolidation
/// challenge is assigned instead of abruptly forcing Level 4.
enum ExertionRating {
  struggled('Kashtam-ah Irundhuchu 😅', 'Felt very tough; needed more rest'),
  justRight('Just Right 👍', 'Challenging but doable; perfect pace'),
  easy('Too Easy ⚡', 'Could easily do more; ready to level up');

  final String label;
  final String description;

  const ExertionRating(this.label, this.description);
}

class AntiRobotState {
  final int currentLevel; // 1 to 5
  final String levelTitle;
  final bool isConsolidating; // true if repeated equivalent challenge active
  final String? lastExertionFeedback;
  final int completedWorkoutsAtLevel;
  final String coachNote;

  const AntiRobotState({
    this.currentLevel = 2,
    this.levelTitle = 'Level 2: Habit Builder',
    this.isConsolidating = false,
    this.lastExertionFeedback,
    this.completedWorkoutsAtLevel = 1,
    this.coachNote = 'Adaptive progression active. We calibrate to your real stamina.',
  });

  AntiRobotState copyWith({
    int? currentLevel,
    String? levelTitle,
    bool? isConsolidating,
    String? lastExertionFeedback,
    int? completedWorkoutsAtLevel,
    String? coachNote,
  }) {
    return AntiRobotState(
      currentLevel: currentLevel ?? this.currentLevel,
      levelTitle: levelTitle ?? this.levelTitle,
      isConsolidating: isConsolidating ?? this.isConsolidating,
      lastExertionFeedback: lastExertionFeedback ?? this.lastExertionFeedback,
      completedWorkoutsAtLevel: completedWorkoutsAtLevel ?? this.completedWorkoutsAtLevel,
      coachNote: coachNote ?? this.coachNote,
    );
  }

  static String getTitleForLevel(int level) {
    switch (level) {
      case 1:
        return 'Level 1: Gentle Starter';
      case 2:
        return 'Level 2: Habit Builder';
      case 3:
        return 'Level 3: Stamina Challenger';
      case 4:
        return 'Level 4: Athletic Mover';
      case 5:
        return 'Level 5: Peak Warrior';
      default:
        return 'Level $level: Progressor';
    }
  }

  Map<String, dynamic> toJson() => {
    'current_level': currentLevel,
    'level_title': levelTitle,
    'is_consolidating': isConsolidating,
    'last_exertion_feedback': lastExertionFeedback,
    'completed_workouts_at_level': completedWorkoutsAtLevel,
    'coach_note': coachNote,
  };

  factory AntiRobotState.fromJson(Map<String, dynamic> json) {
    return AntiRobotState(
      currentLevel: json['current_level'] as int? ?? 2,
      levelTitle: json['level_title'] as String? ?? 'Level 2: Habit Builder',
      isConsolidating: json['is_consolidating'] as bool? ?? false,
      lastExertionFeedback: json['last_exertion_feedback'] as String?,
      completedWorkoutsAtLevel: json['completed_workouts_at_level'] as int? ?? 1,
      coachNote: json['coach_note'] as String? ?? 'Adaptive progression active.',
    );
  }
}

