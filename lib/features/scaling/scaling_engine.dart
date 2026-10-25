import '../../core/models/daily_checkin.dart';
import '../../core/models/daily_target.dart';
import '../../core/models/readiness_result.dart';
import '../../core/models/workout.dart';

/// Pure Dart Dynamic Scaling Engine
/// Adapts daily fitness targets (steps, active minutes, and suggested routine)
/// according to the user's readiness score, life load, injuries, and cycle phase.
class ScalingEngine {
  const ScalingEngine();

  /// Calculate the daily adapted target based on ReadinessResult, user base preferences, and manual overrides
  DailyTarget scale({
    required String userId,
    required ReadinessResult readiness,
    required DailyCheckin checkin,
    List<Workout> availableWorkouts = const [],
    int baseSteps = 8000,
    int baseActiveMinutes = 30,
    int manualOverride = 0, // -1: easier, 0: auto, 1: harder
    bool isIntentionalRestDay = false,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Calculate Base Scaling Percentage
    int scalingPercentage;
    bool isPushDay = false;

    if (isIntentionalRestDay) {
      scalingPercentage = 0;
    } else {
      switch (readiness.band) {
        case ReadinessBand.rest:
          scalingPercentage = 30;
          break;
        case ReadinessBand.light:
          scalingPercentage = 55;
          break;
        case ReadinessBand.moderate:
          scalingPercentage = 75;
          break;
        case ReadinessBand.optimal:
          scalingPercentage = 100;
          break;
        case ReadinessBand.peak:
          scalingPercentage = 115;
          isPushDay = true;
          break;
      }
    }

    // 2. Apply Manual Override (-1: -20%, +1: +20%)
    if (!isIntentionalRestDay) {
      if (manualOverride == -1) {
        scalingPercentage = (scalingPercentage - 20).clamp(20, 140);
      } else if (manualOverride == 1) {
        scalingPercentage = (scalingPercentage + 20).clamp(20, 140);
        if (scalingPercentage >= 115) {
          isPushDay = true;
        }
      }
    }

    // 3. Compute Adapted Targets
    final double ratio = scalingPercentage / 100.0;
    final int adaptedSteps = isIntentionalRestDay ? 0 : (baseSteps * ratio).round();
    final int adaptedMinutes = isIntentionalRestDay ? 0 : (baseActiveMinutes * ratio).round().clamp(10, 90);

    // 4. Select Best Matching Workout Routine
    final workoutSuggestion = _selectSuggestedWorkout(
      readiness: readiness,
      checkin: checkin,
      scalingPercentage: scalingPercentage,
      availableWorkouts: availableWorkouts,
      isRestDay: isIntentionalRestDay,
    );

    return DailyTarget(
      id: '${userId}_${today.year}_${today.month}_${today.day}',
      userId: userId,
      date: today,
      baseSteps: baseSteps,
      adaptedSteps: adaptedSteps,
      baseActiveMinutes: baseActiveMinutes,
      adaptedActiveMinutes: adaptedMinutes,
      scalingPercentage: scalingPercentage,
      suggestedWorkoutId: workoutSuggestion.id,
      suggestedWorkoutTitle: workoutSuggestion.name,
      userManualOverride: manualOverride,
      isPushDay: isPushDay,
      isIntentionalRestDay: isIntentionalRestDay,
      isCompleted: false,
    );
  }

  /// Internal selector to find the optimal workout routine
  ({String id, String name}) _selectSuggestedWorkout({
    required ReadinessResult readiness,
    required DailyCheckin checkin,
    required int scalingPercentage,
    required List<Workout> availableWorkouts,
    required bool isRestDay,
  }) {
    if (isRestDay) {
      return (
        id: 'rest_day_recovery',
        name: 'Guilt-Free Intentional Rest',
      );
    }

    // Exam day or high stress or cycle menstrual
    if (checkin.isExamDay || checkin.stressLevel >= 4) {
      return (
        id: 'quick_15_calm_mobility',
        name: 'Quick 15-Min Brain-Clear Mobility',
      );
    }

    if (checkin.cyclePhase?.toLowerCase() == 'menstrual') {
      return (
        id: 'cramp_relief_gentle_flow',
        name: 'Cramp-Relief Gentle Flow & Restorative Stretch',
      );
    }

    if (readiness.band == ReadinessBand.rest) {
      return (
        id: 'light_walking_breathing',
        name: '15-Min Light Walking & Stress Reset',
      );
    }

    if (readiness.band == ReadinessBand.light) {
      return (
        id: 'desk_worker_spine_mobility',
        name: '20-Min Spine & Hip Mobility Flow',
      );
    }

    if (readiness.band == ReadinessBand.moderate) {
      return (
        id: 'bodyweight_endurance_starter',
        name: '25-Min Zero-Equipment Tone & Core',
      );
    }

    if (readiness.band == ReadinessBand.peak) {
      return (
        id: 'peak_full_body_power',
        name: 'Push Day: 35-Min High Energy Power Circuit',
      );
    }

    // Default optimal
    return (
      id: 'full_body_strength_revitalizer',
      name: '30-Min Dynamic Full Body Strength',
    );
  }
}
