/// Configuration weights for the rule-based Readiness Engine.
/// Stored in config so they can be tuned without changing algorithm logic.
class ReadinessWeights {
  final double scheduleWeight;
  final double sleepWeight;
  final double stressMoodWeight;
  final double recoveryWeight;

  // Modifiers
  final double examPenalty;
  final double deadlinePenalty;
  final double highStressPenalty;
  final double cycleMenstrualModifier;
  final double cycleFollicularModifier;
  final double mildInjuryPenalty;
  final double moderateInjuryPenalty;
  final double severeInjuryPenalty;

  const ReadinessWeights({
    this.scheduleWeight = 0.25,
    this.sleepWeight = 0.30,
    this.stressMoodWeight = 0.25,
    this.recoveryWeight = 0.20,
    this.examPenalty = 35.0,
    this.deadlinePenalty = 20.0,
    this.highStressPenalty = 20.0,
    this.cycleMenstrualModifier = -15.0,
    this.cycleFollicularModifier = 5.0,
    this.mildInjuryPenalty = 10.0,
    this.moderateInjuryPenalty = 25.0,
    this.severeInjuryPenalty = 40.0,
  });

  /// Factory for standard default weights
  factory ReadinessWeights.standard() => const ReadinessWeights();

  /// Create a copy with overrides for B2B partners or experiments
  ReadinessWeights copyWith({
    double? scheduleWeight,
    double? sleepWeight,
    double? stressMoodWeight,
    double? recoveryWeight,
    double? examPenalty,
    double? deadlinePenalty,
    double? highStressPenalty,
    double? cycleMenstrualModifier,
    double? cycleFollicularModifier,
    double? mildInjuryPenalty,
    double? moderateInjuryPenalty,
    double? severeInjuryPenalty,
  }) {
    return ReadinessWeights(
      scheduleWeight: scheduleWeight ?? this.scheduleWeight,
      sleepWeight: sleepWeight ?? this.sleepWeight,
      stressMoodWeight: stressMoodWeight ?? this.stressMoodWeight,
      recoveryWeight: recoveryWeight ?? this.recoveryWeight,
      examPenalty: examPenalty ?? this.examPenalty,
      deadlinePenalty: deadlinePenalty ?? this.deadlinePenalty,
      highStressPenalty: highStressPenalty ?? this.highStressPenalty,
      cycleMenstrualModifier: cycleMenstrualModifier ?? this.cycleMenstrualModifier,
      cycleFollicularModifier: cycleFollicularModifier ?? this.cycleFollicularModifier,
      mildInjuryPenalty: mildInjuryPenalty ?? this.mildInjuryPenalty,
      moderateInjuryPenalty: moderateInjuryPenalty ?? this.moderateInjuryPenalty,
      severeInjuryPenalty: severeInjuryPenalty ?? this.severeInjuryPenalty,
    );
  }

  Map<String, dynamic> toJson() => {
    'scheduleWeight': scheduleWeight,
    'sleepWeight': sleepWeight,
    'stressMoodWeight': stressMoodWeight,
    'recoveryWeight': recoveryWeight,
    'examPenalty': examPenalty,
    'deadlinePenalty': deadlinePenalty,
    'highStressPenalty': highStressPenalty,
    'cycleMenstrualModifier': cycleMenstrualModifier,
    'cycleFollicularModifier': cycleFollicularModifier,
    'mildInjuryPenalty': mildInjuryPenalty,
    'moderateInjuryPenalty': moderateInjuryPenalty,
    'severeInjuryPenalty': severeInjuryPenalty,
  };
}
