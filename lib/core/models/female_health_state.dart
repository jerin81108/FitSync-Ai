/// Female Health Sync Engine Model
/// Covers Menstrual Cycle Tracking (Day 1-3 Period Guard),
/// PCOS/PCOD Hormonal Balance Mode, and Indoor vs Outdoor Safety Switching.
enum CyclePhase {
  menstrual('Menstrual (Period Day 1-3)', '🩸', 'Low energy, pelvic cramps. High weights swapped for cramp-relief yoga & walking.'),
  follicular('Follicular Phase (Days 4-11)', '🌱', 'Estrogen rising. Stamina and strength gradually rebuilding.'),
  ovulatory('Ovulatory Peak (Days 12-16)', '⚡', 'Peak energy & power. Ideal for high endurance and PRs.'),
  luteal('Luteal Phase (Days 17-28)', '🌙', 'Progesterone phase. PMS awareness, steady moderate pacing.');

  final String label;
  final String emoji;
  final String description;

  const CyclePhase(this.label, this.emoji, this.description);
}

enum WorkoutEnvironment {
  indoor('Indoor (Home / Zero Equipment) 🏠', 'Quick 15-min equipment-free routine. Safe, private, and fast.'),
  outdoor('Outdoor (Park / Running) 🌳', 'Open-air walking, running, or jogging.');

  final String label;
  final String description;

  const WorkoutEnvironment(this.label, this.description);
}

class FemaleHealthState {
  final bool isCycleTrackingEnabled;
  final CyclePhase currentPhase;
  final int periodDay; // 1 to 5 if in menstrual
  final bool isPcosPcodMode;
  final WorkoutEnvironment workoutEnvironment;
  final bool isCrampReliefActive;

  const FemaleHealthState({
    this.isCycleTrackingEnabled = false,
    this.currentPhase = CyclePhase.follicular,
    this.periodDay = 1,
    this.isPcosPcodMode = false,
    this.workoutEnvironment = WorkoutEnvironment.indoor,
    this.isCrampReliefActive = false,
  });

  FemaleHealthState copyWith({
    bool? isCycleTrackingEnabled,
    CyclePhase? currentPhase,
    int? periodDay,
    bool? isPcosPcodMode,
    WorkoutEnvironment? workoutEnvironment,
    bool? isCrampReliefActive,
  }) {
    return FemaleHealthState(
      isCycleTrackingEnabled: isCycleTrackingEnabled ?? this.isCycleTrackingEnabled,
      currentPhase: currentPhase ?? this.currentPhase,
      periodDay: periodDay ?? this.periodDay,
      isPcosPcodMode: isPcosPcodMode ?? this.isPcosPcodMode,
      workoutEnvironment: workoutEnvironment ?? this.workoutEnvironment,
      isCrampReliefActive: isCrampReliefActive ?? this.isCrampReliefActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_cycle_tracking_enabled': isCycleTrackingEnabled,
    'current_phase': currentPhase.name,
    'period_day': periodDay,
    'is_pcos_pcod_mode': isPcosPcodMode,
    'workout_environment': workoutEnvironment.name,
    'is_cramp_relief_active': isCrampReliefActive,
  };

  factory FemaleHealthState.fromJson(Map<String, dynamic> json) {
    return FemaleHealthState(
      isCycleTrackingEnabled: json['is_cycle_tracking_enabled'] as bool? ?? false,
      currentPhase: CyclePhase.values.firstWhere(
        (c) => c.name == json['current_phase'],
        orElse: () => CyclePhase.follicular,
      ),
      periodDay: json['period_day'] as int? ?? 1,
      isPcosPcodMode: json['is_pcos_pcod_mode'] as bool? ?? false,
      workoutEnvironment: WorkoutEnvironment.values.firstWhere(
        (e) => e.name == json['workout_environment'],
        orElse: () => WorkoutEnvironment.indoor,
      ),
      isCrampReliefActive: json['is_cramp_relief_active'] as bool? ?? false,
    );
  }
}

