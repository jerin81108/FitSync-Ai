import 'package:test/test.dart';
import 'package:fitsync_ai/core/config/readiness_weights.dart';
import 'package:fitsync_ai/core/models/daily_checkin.dart';
import 'package:fitsync_ai/core/models/readiness_result.dart';
import 'package:fitsync_ai/core/models/streak_data.dart';
import 'package:fitsync_ai/features/readiness/readiness_engine.dart';
import 'package:fitsync_ai/features/scaling/scaling_engine.dart';
import 'package:fitsync_ai/features/streaks/streak_engine.dart';
import 'package:fitsync_ai/features/workouts/workout_library.dart';

void main() {
  const readinessEngine = ReadinessEngine();
  const scalingEngine = ScalingEngine();
  const streakEngine = StreakEngine();

  group('FitSync AI Core Engines - 27 Exhaustive Verification Scenarios', () {
    // -------------------------------------------------------------------------
    // SCENARIO 1: Exam Day + Low Sleep + High Stress -> ~30% Target
    // -------------------------------------------------------------------------
    test('Scenario 1: Exam day + 4.5h sleep + stress 5 -> target scales to ~30%', () {
      final checkin = DailyCheckin(
        id: 'c1',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.exhausted,
        stressLevel: 5,
        sleepHours: 4.5,
        sleepQuality: 1,
        scheduleLoadRating: 90,
        isExamDay: true,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.score, lessThan(40));
      expect(readiness.band, equals(ReadinessBand.rest));

      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        baseSteps: 8000,
        baseActiveMinutes: 30,
      );

      expect(target.scalingPercentage, equals(30));
      expect(target.adaptedSteps, equals(2400)); // 8000 * 0.30
      expect(target.adaptedActiveMinutes, lessThanOrEqualTo(15));
      expect(target.suggestedWorkoutTitle, contains('15-Min'));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 2: Normal Day + Good Sleep + Good Mood -> 100% Target
    // -------------------------------------------------------------------------
    test('Scenario 2: Normal day + 8.0h sleep + good mood -> 100% target', () {
      final checkin = DailyCheckin(
        id: 'c2',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.good,
        stressLevel: 2,
        sleepHours: 8.0,
        sleepQuality: 4,
        scheduleLoadRating: 20,
        yesterdayWorkoutIntensity: 2,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.score, inInclusiveRange(80, 92));
      expect(readiness.band, equals(ReadinessBand.optimal));

      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        baseSteps: 8000,
        baseActiveMinutes: 30,
      );

      expect(target.scalingPercentage, equals(100));
      expect(target.adaptedSteps, equals(8000));
      expect(target.adaptedActiveMinutes, equals(30));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 3: Peak Recovery + Great Mood + Zen Stress -> Peak Push Day
    // -------------------------------------------------------------------------
    test('Scenario 3: Peak recovery + great mood + low stress -> Peak push day (>92 score)', () {
      final checkin = DailyCheckin(
        id: 'c3',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.great,
        stressLevel: 1,
        sleepHours: 8.5,
        sleepQuality: 5,
        scheduleLoadRating: 5,
        yesterdayWorkoutIntensity: 1,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.score, greaterThanOrEqualTo(93));
      expect(readiness.band, equals(ReadinessBand.peak));

      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      );

      expect(target.isPushDay, isTrue);
      expect(target.scalingPercentage, greaterThan(100));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 4: Deadline Marked -> Target Dials to Moderate (60-75%)
    // -------------------------------------------------------------------------
    test('Scenario 4: Heavy deadline marked -> target adapts to moderate range', () {
      final checkin = DailyCheckin(
        id: 'c4',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.okay,
        stressLevel: 3,
        sleepHours: 6.5,
        sleepQuality: 3,
        scheduleLoadRating: 50,
        isHeavyDay: true,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.score, inInclusiveRange(45, 75));

      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      );

      expect(target.scalingPercentage, inInclusiveRange(55, 75));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 5: Menstrual Phase Day 1 -> Cycle modifier & cramp relief
    // -------------------------------------------------------------------------
    test('Scenario 5: Cycle menstrual phase -> negative modifier & cramp relief workout', () {
      final checkin = DailyCheckin(
        id: 'c5',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.okay,
        stressLevel: 2,
        sleepHours: 7.5,
        sleepQuality: 3,
        cyclePhase: 'menstrual',
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.cycleModifier, equals(-15.0));

      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      );

      expect(target.suggestedWorkoutId, equals('cramp_relief_gentle_flow'));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 6: Follicular Phase -> Estrogen boost modifier
    // -------------------------------------------------------------------------
    test('Scenario 6: Follicular phase -> positive energy boost modifier (+5.0)', () {
      final checkin = DailyCheckin(
        id: 'c6',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.good,
        stressLevel: 2,
        sleepHours: 7.5,
        sleepQuality: 4,
        cyclePhase: 'follicular',
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.cycleModifier, equals(5.0));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 7: Mild Injury (Knee) -> Penalty (-10) & Lower Body Filter
    // -------------------------------------------------------------------------
    test('Scenario 7: Mild injury (knee) -> -10 pts penalty & knee loading filtered', () {
      final checkin = DailyCheckin(
        id: 'c7',
        userId: 'u1',
        date: DateTime.now(),
        hasActiveInjury: true,
      );

      final readiness = readinessEngine.calculate(checkin: checkin, injurySeverity: 'mild');
      expect(readiness.injuryPenalty, equals(10.0));

      final filteredWorkouts = WorkoutLibrary.filterForInjury(
        workouts: WorkoutLibrary.allWorkouts,
        injuredBodyArea: 'knee',
      );

      // Verify no heavy lower body workout is returned
      final containsHeavyLowerBody = filteredWorkouts.any((w) => w.id == 'lower_body_leg_burn');
      expect(containsHeavyLowerBody, isFalse);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 8: Moderate Injury (Shoulder) -> -25 pts penalty & upper body filtered
    // -------------------------------------------------------------------------
    test('Scenario 8: Moderate shoulder injury -> -25 penalty & upper body filtered', () {
      final checkin = DailyCheckin(
        id: 'c8',
        userId: 'u1',
        date: DateTime.now(),
        hasActiveInjury: true,
      );

      final readiness = readinessEngine.calculate(checkin: checkin, injurySeverity: 'moderate');
      expect(readiness.injuryPenalty, equals(25.0));

      final filtered = WorkoutLibrary.filterForInjury(
        workouts: WorkoutLibrary.allWorkouts,
        injuredBodyArea: 'shoulder',
      );

      final containsUpperStrength = filtered.any((w) => w.id == 'upper_body_strength_focus');
      expect(containsUpperStrength, isFalse);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 9: Severe Injury -> -40 pts penalty
    // -------------------------------------------------------------------------
    test('Scenario 9: Severe injury -> -40 penalty protects user from overexertion', () {
      final checkin = DailyCheckin(
        id: 'c9',
        userId: 'u1',
        date: DateTime.now(),
        hasActiveInjury: true,
      );

      final readiness = readinessEngine.calculate(checkin: checkin, injurySeverity: 'severe');
      expect(readiness.injuryPenalty, equals(40.0));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 10: Manual Override "Make it easier" (-1)
    // -------------------------------------------------------------------------
    test('Scenario 10: Manual override "Make it easier" reduces target by 20%', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin);

      final baseTarget = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        manualOverride: 0,
      );

      final easierTarget = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        manualOverride: -1,
      );

      expect(easierTarget.scalingPercentage, equals(baseTarget.scalingPercentage - 20));
      expect(easierTarget.adaptedSteps, lessThan(baseTarget.adaptedSteps));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 11: Manual Override "Make it harder" (+1)
    // -------------------------------------------------------------------------
    test('Scenario 11: Manual override "Make it harder" increases target by 20%', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin);

      final baseTarget = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        manualOverride: 0,
      );

      final harderTarget = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        manualOverride: 1,
      );

      expect(harderTarget.scalingPercentage, equals(baseTarget.scalingPercentage + 20));
      expect(harderTarget.adaptedSteps, greaterThan(baseTarget.adaptedSteps));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 12: Intentional Rest Day -> Target 0, Streak Preserved
    // -------------------------------------------------------------------------
    test('Scenario 12: Intentional rest day produces 0 steps target and preserves streak', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin);

      final restTarget = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        isIntentionalRestDay: true,
      );

      expect(restTarget.adaptedSteps, equals(0));
      expect(restTarget.isIntentionalRestDay, isTrue);

      final initialStreak = StreakData.initial(userId: 'u1');
      final result = streakEngine.processDay(
        currentStreak: initialStreak,
        target: restTarget,
        checkin: checkin,
      );

      expect(result.streakContinued, isTrue);
      expect(result.restDayApplied, isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 13: Exam Day Rest -> Never breaks streak & awards Exam Warrior badge
    // -------------------------------------------------------------------------
    test('Scenario 13: Rest on exam day keeps streak and awards Exam Warrior badge', () {
      final checkin = DailyCheckin(
        id: 'c13',
        userId: 'u1',
        date: DateTime.now(),
        isExamDay: true,
      );
      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        isIntentionalRestDay: true,
      );

      final streak = StreakData.initial(userId: 'u1').copyWith(
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      final eval = streakEngine.processDay(
        currentStreak: streak,
        target: target,
        checkin: checkin,
      );

      expect(eval.streakContinued, isTrue);
      expect(eval.newlyUnlockedBadges.any((b) => b.key == 'exam_warrior'), isTrue);
      expect(eval.coachCheerMessage, contains('Exam day rest honored'));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 14: Rest on Heavy Day -> Never breaks streak & awards Zero Guilt Master
    // -------------------------------------------------------------------------
    test('Scenario 14: Heavy day rest awards Zero Guilt Master badge', () {
      final checkin = DailyCheckin(
        id: 'c14',
        userId: 'u1',
        date: DateTime.now(),
        isHeavyDay: true,
      );
      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
        isIntentionalRestDay: true,
      );

      final streak = StreakData.initial(userId: 'u1').copyWith(
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      final eval = streakEngine.processDay(
        currentStreak: streak,
        target: target,
        checkin: checkin,
      );

      expect(eval.streakContinued, isTrue);
      expect(eval.newlyUnlockedBadges.any((b) => b.key == 'zero_guilt_master'), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 15: Working Out While Tired -> Awards Showed Up Tired Badge
    // -------------------------------------------------------------------------
    test('Scenario 15: Completing target while exhausted awards Showed Up Tired badge', () {
      final checkin = DailyCheckin(
        id: 'c15',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.exhausted,
      );
      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      ).copyWith(isCompleted: true);

      final streak = StreakData.initial(userId: 'u1').copyWith(
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      final eval = streakEngine.processDay(
        currentStreak: streak,
        target: target,
        checkin: checkin,
      );

      expect(eval.newlyUnlockedBadges.any((b) => b.key == 'showed_up_tired'), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 16: First Workout Completion -> Awards First Step Badge
    // -------------------------------------------------------------------------
    test('Scenario 16: First workout completion awards First Step badge', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      ).copyWith(isCompleted: true);

      const streak = StreakData(userId: 'u1', currentStreak: 0);
      final eval = streakEngine.processDay(
        currentStreak: streak,
        target: target,
        checkin: checkin,
      );

      expect(eval.newlyUnlockedBadges.any((b) => b.key == 'first_step'), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 17: Reaching 7 Consecutive Days -> Awards 7-Day Flex Badge
    // -------------------------------------------------------------------------
    test('Scenario 17: Reaching streak 7 awards 7-Day Flex badge', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      ).copyWith(isCompleted: true);

      final streak = StreakData.initial(userId: 'u1').copyWith(
        currentStreak: 6,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      final eval = streakEngine.processDay(
        currentStreak: streak,
        target: target,
        checkin: checkin,
      );

      expect(eval.updatedStreak.currentStreak, equals(7));
      expect(eval.newlyUnlockedBadges.any((b) => b.key == 'seven_day_flex'), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 18: Streak Freeze Saves Unlogged Day
    // -------------------------------------------------------------------------
    test('Scenario 18: Missing a day consumes a freeze and preserves streak', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      ).copyWith(isCompleted: true);

      // Missed 2 days ago
      final streak = StreakData.initial(userId: 'u1').copyWith(
        currentStreak: 5,
        streakFreezesLeft: 2,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 2)),
      );

      final eval = streakEngine.processDay(
        currentStreak: streak,
        target: target,
        checkin: checkin,
      );

      expect(eval.updatedStreak.currentStreak, equals(6));
      expect(eval.updatedStreak.streakFreezesLeft, equals(1));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 19: Compassionate Reset When Freezes Exhausted
    // -------------------------------------------------------------------------
    test('Scenario 19: Compassionate reset message when gap exceeds freezes', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      ); // Not completed

      final streak = StreakData.initial(userId: 'u1').copyWith(
        currentStreak: 10,
        streakFreezesLeft: 0,
        lastActivityDate: DateTime.now().subtract(const Duration(days: 3)),
      );

      final eval = streakEngine.processDay(
        currentStreak: streak,
        target: target,
        checkin: checkin,
      );

      expect(eval.updatedStreak.currentStreak, equals(1));
      expect(eval.coachCheerMessage, contains('Fresh start today'));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 20: Very Short Sleep (3 hrs) With Good Mood
    // -------------------------------------------------------------------------
    test('Scenario 20: Severe sleep deficit (3.0h) pulls readiness down even with good mood', () {
      final checkin = DailyCheckin(
        id: 'c20',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.good,
        stressLevel: 2,
        sleepHours: 3.0,
        sleepQuality: 1,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.score, lessThan(60));
      expect(readiness.explanations.any((e) => e.factorName.contains('Short Sleep')), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 21: High Sleep (10 hrs) But Overwhelmed Stress (Level 5)
    // -------------------------------------------------------------------------
    test('Scenario 21: Overwhelmed stress level 5 pulls down readiness despite 10h sleep', () {
      final checkin = DailyCheckin(
        id: 'c21',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.low,
        stressLevel: 5,
        sleepHours: 10.0,
        sleepQuality: 3,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.score, lessThan(65));
      expect(readiness.explanations.any((e) => e.factorName.contains('Stress')), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 22: Short Free Time (15 mins) Selects Quick-15
    // -------------------------------------------------------------------------
    test('Scenario 22: Available free time 15 mins triggers quick-15 adaptation', () {
      final checkin = DailyCheckin.defaultToday(userId: 'u1');
      final readiness = readinessEngine.calculate(checkin: checkin, availableMinutes: 15);

      expect(readiness.explanations.any((e) => e.factorName.contains('Short Time Slot')), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 23: Heavy Workout Yesterday (Intensity 5) Demands Recovery
    // -------------------------------------------------------------------------
    test('Scenario 23: Exhausting workout yesterday (level 5) penalizes recovery factor', () {
      final checkin = DailyCheckin(
        id: 'c23',
        userId: 'u1',
        date: DateTime.now(),
        yesterdayWorkoutIntensity: 5,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.recoveryFactor, equals(30.0));
      expect(readiness.explanations.any((e) => e.factorName.contains('Heavy Workout Yesterday')), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 24: Rested Yesterday (Intensity 0) Gives Recovery Boost
    // -------------------------------------------------------------------------
    test('Scenario 24: Full rest day yesterday (intensity 0) awards high recovery score (95)', () {
      final checkin = DailyCheckin(
        id: 'c24',
        userId: 'u1',
        date: DateTime.now(),
        yesterdayWorkoutIntensity: 0,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      expect(readiness.recoveryFactor, equals(95.0));
      expect(readiness.explanations.any((e) => e.factorName.contains('Well Rested')), isTrue);
    });

    // -------------------------------------------------------------------------
    // SCENARIO 25: Compounding Stressors Respect Safe Floor (>= 5 pts)
    // -------------------------------------------------------------------------
    test('Scenario 25: Quadruple stressors respect safety floor and never go negative', () {
      final checkin = DailyCheckin(
        id: 'c25',
        userId: 'u1',
        date: DateTime.now(),
        mood: MoodEmoji.exhausted,
        stressLevel: 5,
        sleepHours: 2.0,
        sleepQuality: 1,
        scheduleLoadRating: 100,
        isExamDay: true,
        cyclePhase: 'menstrual',
        hasActiveInjury: true,
      );

      final readiness = readinessEngine.calculate(checkin: checkin, injurySeverity: 'severe');
      expect(readiness.score, greaterThanOrEqualTo(5));
      expect(readiness.score, lessThanOrEqualTo(100));
      expect(readiness.band, equals(ReadinessBand.rest));

      final target = scalingEngine.scale(
        userId: 'u1',
        readiness: readiness,
        checkin: checkin,
      );
      expect(target.scalingPercentage, equals(30));
    });

    // -------------------------------------------------------------------------
    // SCENARIO 26: Injury Filter Excludes Lower-Body for Ankle Injury
    // -------------------------------------------------------------------------
    test('Scenario 26: Ankle injury filters out lower body heavy workouts', () {
      final filtered = WorkoutLibrary.filterForInjury(
        workouts: WorkoutLibrary.allWorkouts,
        injuredBodyArea: 'ankle',
      );

      for (final w in filtered) {
        if (w.bodyRegion == 'lower_body') {
          expect(w.tags.contains('low-impact'), isTrue);
        }
      }
    });

    // -------------------------------------------------------------------------
    // SCENARIO 27: Tunable Config Weights Applied Correctly
    // -------------------------------------------------------------------------
    test('Scenario 27: Custom ReadinessWeights modify scoring dynamically', () {
      const customWeights = ReadinessWeights(
        scheduleWeight: 0.50, // Heavily weight schedule
        sleepWeight: 0.10,
        stressMoodWeight: 0.20,
        recoveryWeight: 0.20,
      );

      const customEngine = ReadinessEngine(weights: customWeights);
      final checkin = DailyCheckin(
        id: 'c27',
        userId: 'u1',
        date: DateTime.now(),
        scheduleLoadRating: 90,
      );

      final customReadiness = customEngine.calculate(checkin: checkin);
      final standardReadiness = readinessEngine.calculate(checkin: checkin);

      expect(customReadiness.score, lessThan(standardReadiness.score));
    });
  });
}
