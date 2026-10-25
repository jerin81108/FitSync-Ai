import '../../core/config/readiness_weights.dart';
import '../../core/models/daily_checkin.dart';
import '../../core/models/readiness_result.dart';

/// Pure Dart, rule-based Readiness Engine.
/// Transparent, unit-tested, and fully decoupled from UI or Flutter frameworks.
class ReadinessEngine {
  final ReadinessWeights weights;

  const ReadinessEngine({this.weights = const ReadinessWeights()});

  /// Calculate the daily readiness score and factor explanations
  ReadinessResult calculate({
    required DailyCheckin checkin,
    int? availableMinutes,
    String? injurySeverity, // 'mild', 'moderate', 'severe', or null
  }) {
    final explanations = <ReadinessFactorExplanation>[];

    // 1. Schedule Load Component (0-100)
    double scheduleScore = (100 - checkin.scheduleLoadRating).toDouble().clamp(0.0, 100.0);
    double scheduleDeduction = 0.0;

    if (checkin.isExamDay) {
      scheduleDeduction += weights.examPenalty;
      explanations.add(const ReadinessFactorExplanation(
        factorName: 'Exam Day Flagged',
        detail: 'Exams require intense cognitive energy. Daily target dialed down to protect your focus and eliminate guilt.',
        impactPoints: -35.0,
        icon: '🎓',
      ));
    } else if (checkin.isHeavyDay) {
      scheduleDeduction += weights.deadlinePenalty;
      explanations.add(const ReadinessFactorExplanation(
        factorName: 'Heavy Schedule Marked',
        detail: 'Busy deadlines or long classes. Target reduced to fit your available bandwidth.',
        impactPoints: -20.0,
        icon: '📅',
      ));
    } else if (scheduleScore >= 75) {
      explanations.add(const ReadinessFactorExplanation(
        factorName: 'Open Schedule',
        detail: 'Light schedule today allows more headroom for physical activity.',
        impactPoints: 10.0,
        icon: '✨',
      ));
    }
    scheduleScore = (scheduleScore - scheduleDeduction).clamp(0.0, 100.0);

    // 2. Sleep Component (0-100)
    final double sleepDurationScore = _calculateSleepDurationScore(checkin.sleepHours);
    final double sleepQualityScore = _calculateSleepQualityScore(checkin.sleepQuality);
    final double sleepCombined = (sleepDurationScore * 0.70) + (sleepQualityScore * 0.30);

    if (checkin.sleepHours < 5.5) {
      explanations.add(ReadinessFactorExplanation(
        factorName: 'Short Sleep (${checkin.sleepHours} hrs)',
        detail: 'Under 5.5 hours limits muscular and neural recovery. Target adapted for gentle restoration.',
        impactPoints: -25.0,
        icon: '😴',
      ));
    } else if (checkin.sleepHours >= 7.5 && checkin.sleepQuality >= 4) {
      explanations.add(ReadinessFactorExplanation(
        factorName: 'Great Sleep (${checkin.sleepHours} hrs, Quality ${checkin.sleepQuality}/5)',
        detail: 'Deep, restorative rest provides high physical resilience.',
        impactPoints: 15.0,
        icon: '🌙',
      ));
    } else {
      explanations.add(ReadinessFactorExplanation(
        factorName: 'Moderate Sleep (${checkin.sleepHours} hrs)',
        detail: 'Adequate rest for standard daily movement.',
        impactPoints: 0.0,
        icon: '🛏️',
      ));
    }

    // 3. Stress & Mood Component (0-100)
    final double moodScore = _calculateMoodScore(checkin.mood);
    final double stressScore = _calculateStressScore(checkin.stressLevel);
    final double stressMoodCombined = (moodScore * 0.50) + (stressScore * 0.50);

    if (checkin.stressLevel >= 4 || checkin.mood == MoodEmoji.exhausted) {
      explanations.add(ReadinessFactorExplanation(
        factorName: 'Elevated Stress & Fatigue (${checkin.mood.label}, Stress ${checkin.stressLevel}/5)',
        detail: 'High mental load elevates cortisol. We swap intense workouts for stress-reducing mobility.',
        impactPoints: -20.0,
        icon: '🧘',
      ));
    } else if (checkin.mood == MoodEmoji.great && checkin.stressLevel <= 2) {
      explanations.add(const ReadinessFactorExplanation(
        factorName: 'Energized & Focused',
        detail: 'High mood and calm nervous system support peak performance.',
        impactPoints: 10.0,
        icon: '🔥',
      ));
    }

    // 4. Recovery Component from Yesterday's Intensity (0-100)
    final double recoveryScore = _calculateRecoveryScore(checkin.yesterdayWorkoutIntensity);
    if (checkin.yesterdayWorkoutIntensity >= 4) {
      explanations.add(const ReadinessFactorExplanation(
        factorName: 'Heavy Workout Yesterday',
        detail: 'Muscles are repairing today. A lighter load promotes blood flow without overtraining.',
        impactPoints: -15.0,
        icon: '💪',
      ));
    } else if (checkin.yesterdayWorkoutIntensity <= 1) {
      explanations.add(const ReadinessFactorExplanation(
        factorName: 'Well Rested',
        detail: 'Minimal muscle fatigue from yesterday.',
        impactPoints: 5.0,
        icon: '⚡',
      ));
    }

    // 5. Available Time Factor
    double availableTimeFactor = 100.0;
    if (availableMinutes != null && availableMinutes < 30) {
      availableTimeFactor = (availableMinutes / 30.0 * 100.0).clamp(20.0, 100.0);
      explanations.add(ReadinessFactorExplanation(
        factorName: 'Short Time Slot ($availableMinutes mins)',
        detail: 'Adapting to a rapid zero-equipment 15-minute routine.',
        impactPoints: -10.0,
        icon: '⏱️',
      ));
    }

    // 6. Base Weighted Score Calculation
    final double weightedBase = (scheduleScore * weights.scheduleWeight) +
        (sleepCombined * weights.sleepWeight) +
        (stressMoodCombined * weights.stressMoodWeight) +
        (recoveryScore * weights.recoveryWeight);

    // 7. Modifiers
    double cycleModifier = 0.0;
    if (checkin.cyclePhase != null) {
      final phase = checkin.cyclePhase!.toLowerCase();
      if (phase == 'menstrual') {
        cycleModifier = weights.cycleMenstrualModifier;
        explanations.add(const ReadinessFactorExplanation(
          factorName: 'Cycle Phase: Menstrual',
          detail: 'Hormonal energy naturally dips. High intensity swapped for cramp-relief & gentle stretching.',
          impactPoints: -15.0,
          icon: '🌸',
        ));
      } else if (phase == 'follicular' || phase == 'ovulatory') {
        cycleModifier = weights.cycleFollicularModifier;
        explanations.add(const ReadinessFactorExplanation(
          factorName: 'Cycle Phase: High Energy Phase',
          detail: 'Estrogen peak supports stamina and strength gains.',
          impactPoints: 5.0,
          icon: '✨',
        ));
      }
    }

    double injuryPenalty = 0.0;
    if (checkin.hasActiveInjury || injurySeverity != null) {
      final severity = (injurySeverity ?? 'moderate').toLowerCase();
      if (severity == 'mild') {
        injuryPenalty = weights.mildInjuryPenalty;
      } else if (severity == 'severe') {
        injuryPenalty = weights.severeInjuryPenalty;
      } else {
        injuryPenalty = weights.moderateInjuryPenalty;
      }
      explanations.add(ReadinessFactorExplanation(
        factorName: 'Active Injury Guard ($severity)',
        detail: 'Protecting injured areas. Offloading affected muscle groups automatically.',
        impactPoints: -injuryPenalty,
        icon: '🛡️',
      ));
    }

    // Severe sleep deprivation and acute stress deductions
    double sleepDeprivationPenalty = 0.0;
    if (checkin.sleepHours < 4.0) {
      sleepDeprivationPenalty = 8.0;
    }

    double highStressDeduction = 0.0;
    if (checkin.stressLevel == 5) {
      highStressDeduction = 10.0;
    } else if (checkin.stressLevel == 4) {
      highStressDeduction = 5.0;
    }

    // 8. Final Clamped Score (5 to 100)
    int finalScore = (weightedBase + cycleModifier - injuryPenalty - sleepDeprivationPenalty - highStressDeduction).round();
    finalScore = finalScore.clamp(5, 100);

    return ReadinessResult(
      score: finalScore,
      band: ReadinessBand.fromScore(finalScore),
      scheduleLoadFactor: scheduleScore,
      sleepFactor: sleepCombined,
      stressMoodFactor: stressMoodCombined,
      recoveryFactor: recoveryScore,
      availableTimeFactor: availableTimeFactor,
      cycleModifier: cycleModifier,
      injuryPenalty: injuryPenalty,
      explanations: explanations,
      calculatedAt: DateTime.now(),
    );
  }

  // --- Subfactor Helpers ---

  double _calculateSleepDurationScore(double hours) {
    if (hours < 4.0) return 15.0;
    if (hours < 5.0) return 30.0;
    if (hours < 6.0) return 55.0;
    if (hours < 7.0) return 75.0;
    if (hours <= 8.5) return 100.0; // Sweet spot
    if (hours <= 9.5) return 90.0;
    return 80.0;
  }

  double _calculateSleepQualityScore(int quality) {
    switch (quality) {
      case 1:
        return 20.0;
      case 2:
        return 40.0;
      case 3:
        return 65.0;
      case 4:
        return 85.0;
      case 5:
        return 100.0;
      default:
        return 60.0;
    }
  }

  double _calculateMoodScore(MoodEmoji mood) {
    switch (mood) {
      case MoodEmoji.great:
        return 100.0;
      case MoodEmoji.good:
        return 85.0;
      case MoodEmoji.okay:
        return 60.0;
      case MoodEmoji.low:
        return 35.0;
      case MoodEmoji.exhausted:
        return 15.0;
    }
  }

  double _calculateStressScore(int stressLevel) {
    switch (stressLevel) {
      case 1:
        return 100.0; // Zen
      case 2:
        return 85.0;
      case 3:
        return 60.0;
      case 4:
        return 35.0;
      case 5:
        return 15.0; // Overwhelmed
      default:
        return 60.0;
    }
  }

  double _calculateRecoveryScore(int yesterdayIntensity) {
    switch (yesterdayIntensity) {
      case 0:
        return 95.0; // Full rest day yesterday
      case 1:
        return 100.0; // Light active recovery
      case 2:
        return 90.0; // Easy day
      case 3:
        return 75.0; // Moderate
      case 4:
        return 50.0; // Hard session
      case 5:
        return 30.0; // Exhausting / Competition
      default:
        return 75.0;
    }
  }
}
