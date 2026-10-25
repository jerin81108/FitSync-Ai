/// Readiness Score Band
enum ReadinessBand {
  rest(0, 39, 'Rest & Recharge', '🌱', 'Your body and mind are carrying a heavy load today. Rest keeps you strong.'),
  light(40, 59, 'Gentle Movement', '🌿', 'Moderate reserves. A light walk or gentle stretch is your sweet spot.'),
  moderate(60, 79, 'Balanced Energy', '⚡', 'Solid baseline! A standard routine will keep momentum steady.'),
  optimal(80, 92, 'Prime Readiness', '🔥', 'You have great capacity today. Ready for full training.'),
  peak(93, 100, 'Unstoppable Peak', '🚀', 'Peak recovery and focus! Today is an optional push day.');

  final int minScore;
  final int maxScore;
  final String label;
  final String emoji;
  final String coachMessage;

  const ReadinessBand(this.minScore, this.maxScore, this.label, this.emoji, this.coachMessage);

  static ReadinessBand fromScore(int score) {
    if (score < 40) return ReadinessBand.rest;
    if (score < 60) return ReadinessBand.light;
    if (score < 80) return ReadinessBand.moderate;
    if (score <= 92) return ReadinessBand.optimal;
    return ReadinessBand.peak;
  }
}

/// Individual explanation item for the "Why is my target this?" bottom sheet
class ReadinessFactorExplanation {
  final String factorName;
  final String detail;
  final double impactPoints; // positive or negative
  final String icon; // Icon identifier or emoji

  const ReadinessFactorExplanation({
    required this.factorName,
    required this.detail,
    required this.impactPoints,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'factor_name': factorName,
    'detail': detail,
    'impact_points': impactPoints,
    'icon': icon,
  };

  factory ReadinessFactorExplanation.fromJson(Map<String, dynamic> json) {
    return ReadinessFactorExplanation(
      factorName: json['factor_name'] as String,
      detail: json['detail'] as String,
      impactPoints: (json['impact_points'] as num).toDouble(),
      icon: json['icon'] as String,
    );
  }
}

/// Comprehensive Readiness calculation result
class ReadinessResult {
  final int score; // 0 to 100
  final ReadinessBand band;
  final double scheduleLoadFactor; // 0 to 100
  final double sleepFactor; // 0 to 100
  final double stressMoodFactor; // 0 to 100
  final double recoveryFactor; // 0 to 100
  final double availableTimeFactor; // 0 to 100
  final double cycleModifier; // Points added or deducted
  final double injuryPenalty; // Points deducted
  final List<ReadinessFactorExplanation> explanations;
  final DateTime calculatedAt;

  const ReadinessResult({
    required this.score,
    required this.band,
    required this.scheduleLoadFactor,
    required this.sleepFactor,
    required this.stressMoodFactor,
    required this.recoveryFactor,
    required this.availableTimeFactor,
    required this.cycleModifier,
    required this.injuryPenalty,
    required this.explanations,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'band': band.name,
    'schedule_load_factor': scheduleLoadFactor,
    'sleep_factor': sleepFactor,
    'stress_mood_factor': stressMoodFactor,
    'recovery_factor': recoveryFactor,
    'available_time_factor': availableTimeFactor,
    'cycle_modifier': cycleModifier,
    'injury_penalty': injuryPenalty,
    'explanations': explanations.map((e) => e.toJson()).toList(),
    'calculated_at': calculatedAt.toIso8601String(),
  };
}
