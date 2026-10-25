import '../../core/models/badge.dart';
import '../../core/models/daily_checkin.dart';
import '../../core/models/daily_target.dart';
import '../../core/models/streak_data.dart';

/// Result of evaluating or advancing a streak
class StreakEvaluationResult {
  final StreakData updatedStreak;
  final bool streakContinued;
  final bool restDayApplied;
  final List<AppBadge> newlyUnlockedBadges;
  final String coachCheerMessage;

  const StreakEvaluationResult({
    required this.updatedStreak,
    required this.streakContinued,
    required this.restDayApplied,
    required this.newlyUnlockedBadges,
    required this.coachCheerMessage,
  });
}

/// Pure Dart No-Guilt Streak Engine
/// Enforces flexible streaks where intentional rest and heavy days preserve progress.
class StreakEngine {
  const StreakEngine();

  /// Process day completion or rest day logging
  StreakEvaluationResult processDay({
    required StreakData currentStreak,
    required DailyTarget target,
    required DailyCheckin checkin,
    List<AppBadge> existingBadges = const [],
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newlyUnlocked = <AppBadge>[];

    // Determine if today counts towards the flex streak
    final bool targetAchieved = target.isCompleted ||
        (target.adaptedSteps > 0 && target.stepsAchieved >= target.adaptedSteps) ||
        (target.adaptedActiveMinutes > 0 && target.activeMinutesAchieved >= target.adaptedActiveMinutes);

    final bool isLegitRestDay = target.isIntentionalRestDay || checkin.isHeavyDay || checkin.isExamDay;

    // Check last activity date
    final lastDate = currentStreak.lastActivityDate != null
        ? DateTime(
            currentStreak.lastActivityDate!.year,
            currentStreak.lastActivityDate!.month,
            currentStreak.lastActivityDate!.day,
          )
        : null;

    final isSameDay = lastDate != null && lastDate.isAtSameMomentAs(today);

    if (isSameDay) {
      // Already logged today
      return StreakEvaluationResult(
        updatedStreak: currentStreak,
        streakContinued: true,
        restDayApplied: isLegitRestDay,
        newlyUnlockedBadges: [],
        coachCheerMessage: 'You already showed up for yourself today! Keep thriving.',
      );
    }

    final int daysSinceLast = lastDate != null ? today.difference(lastDate).inDays : 1;

    int newStreakCount = currentStreak.currentStreak;
    int newActiveDays = currentStreak.totalActiveDays;
    int newRestDays = currentStreak.totalIntentionalRestDays;
    int newFreezes = currentStreak.streakFreezesLeft;
    String cheerMessage;

    if (targetAchieved) {
      // User did their adapted workout or movement
      if (daysSinceLast <= 1) {
        newStreakCount += 1;
      } else if (daysSinceLast == 2 && newFreezes > 0) {
        // Freeze saved yesterday
        newFreezes -= 1;
        newStreakCount += 1;
      } else {
        // Reset gently
        newStreakCount = 1;
      }
      newActiveDays += 1;
      cheerMessage = 'Movement logged! Your streak is burning bright with zero guilt.';
    } else if (isLegitRestDay) {
      // Intentional rest or heavy day rest -> Never breaks streak
      if (daysSinceLast <= 1) {
        newStreakCount += 1;
      } else if (daysSinceLast == 2 && newFreezes > 0) {
        newFreezes -= 1;
        newStreakCount += 1;
      } else {
        newStreakCount = 1;
      }
      newRestDays += 1;
      cheerMessage = checkin.isExamDay
          ? 'Exam day rest honored! Resting on heavy days keeps your streak alive.'
          : 'Intentional rest day logged. Recovery is where resilience is built.';
    } else {
      // Missed with no rest logged
      if (newFreezes > 0) {
        newFreezes -= 1;
        cheerMessage = 'Streak shield protected your progress! Back in action today.';
      } else {
        newStreakCount = 1;
        cheerMessage = 'Fresh start today! Life happens, and your body is ready whenever you are.';
      }
    }

    final int newLongest = newStreakCount > currentStreak.longestStreak ? newStreakCount : currentStreak.longestStreak;

    final updatedStreak = currentStreak.copyWith(
      currentStreak: newStreakCount,
      longestStreak: newLongest,
      totalActiveDays: newActiveDays,
      totalIntentionalRestDays: newRestDays,
      lastActivityDate: today,
      streakFreezesLeft: newFreezes,
      completedDaysThisWeek: [...currentStreak.completedDaysThisWeek, today],
    );

    // Evaluate Badges
    final unlockedKeys = existingBadges.where((b) => b.isUnlocked).map((b) => b.key).toSet();

    if (!unlockedKeys.contains('first_step') && targetAchieved) {
      newlyUnlocked.add(const AppBadge(
        key: 'first_step',
        title: 'First Step',
        description: 'Completed your first adapted workout session in FitSync AI.',
        iconEmoji: '🌱',
        isUnlocked: true,
      ));
    }

    if (!unlockedKeys.contains('exam_warrior') && checkin.isExamDay && (targetAchieved || isLegitRestDay)) {
      newlyUnlocked.add(const AppBadge(
        key: 'exam_warrior',
        title: 'Exam Warrior',
        description: 'Prioritized mental clarity and gentle movement during heavy exam days.',
        iconEmoji: '🎓',
        isUnlocked: true,
      ));
    }

    if (!unlockedKeys.contains('showed_up_tired') &&
        (checkin.mood == MoodEmoji.exhausted || checkin.mood == MoodEmoji.low) &&
        targetAchieved) {
      newlyUnlocked.add(const AppBadge(
        key: 'showed_up_tired',
        title: 'Showed Up Tired',
        description: 'Honored your fatigue with a gentle 15-minute routine instead of burning out.',
        iconEmoji: '😴',
        isUnlocked: true,
      ));
    }

    if (!unlockedKeys.contains('seven_day_flex') && newStreakCount >= 7) {
      newlyUnlocked.add(const AppBadge(
        key: 'seven_day_flex',
        title: '7-Day Flex',
        description: 'Completed 7 consecutive days of adapted movement and intentional rest.',
        iconEmoji: '🌿',
        isUnlocked: true,
      ));
    }

    if (!unlockedKeys.contains('zero_guilt_master') && checkin.isHeavyDay && isLegitRestDay) {
      newlyUnlocked.add(const AppBadge(
        key: 'zero_guilt_master',
        title: 'Zero Guilt Master',
        description: 'Logged an intentional rest day on a heavy day without breaking your streak.',
        iconEmoji: '🛡️',
        isUnlocked: true,
      ));
    }

    return StreakEvaluationResult(
      updatedStreak: updatedStreak,
      streakContinued: true,
      restDayApplied: isLegitRestDay,
      newlyUnlockedBadges: newlyUnlocked,
      coachCheerMessage: cheerMessage,
    );
  }
}
