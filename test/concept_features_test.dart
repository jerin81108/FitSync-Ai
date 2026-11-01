import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync_ai/core/models/anti_robot_state.dart';
import 'package:fitsync_ai/core/models/daily_checkin.dart';
import 'package:fitsync_ai/core/models/female_health_state.dart';
import 'package:fitsync_ai/core/models/readiness_result.dart';
import 'package:fitsync_ai/features/notifications/notification_templates.dart';
import 'package:fitsync_ai/core/models/notification_settings.dart';
import 'package:fitsync_ai/features/readiness/readiness_engine.dart';
import 'package:fitsync_ai/features/scaling/scaling_engine.dart';

void main() {
  group('FitSync AI Specification Tests (Pages 1-8 Concept Implementation)', () {
    const readinessEngine = ReadinessEngine();
    const scalingEngine = ScalingEngine();

    test('1. Anti-Robot Logic: Exertion "Kashtam-ah irundhuchu" triggers consolidation instead of robotic level jump', () {
      final initial = const AntiRobotState(currentLevel: 3, levelTitle: 'Level 3: Stamina Challenger');

      // User struggles with level 3
      final consolidated = initial.copyWith(
        isConsolidating: true,
        lastExertionFeedback: 'struggled',
        coachNote: 'Kashtam-ah irundhucha? No problem! FitSync AI won’t treat you like a robot and force Level 4.',
      );

      expect(consolidated.isConsolidating, true);
      expect(consolidated.currentLevel, 3); // Level remains 3 for consolidation challenge
      expect(consolidated.coachNote, contains('won’t treat you like a robot'));
    });

    test('2. Female Health Sync: Period Day 1-3 automatically scales down targets to cramp-relief & low energy', () {
      final checkin = DailyCheckin.defaultToday(userId: 'test_user').copyWith(
        cyclePhase: 'menstrual',
        stressLevel: 3,
        sleepHours: 7.0,
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'test_user',
        readiness: readiness,
        checkin: checkin,
      );

      // Target suggests cramp-relief yoga
      expect(target.suggestedWorkoutId, 'cramp_relief_gentle_flow');
      expect(target.suggestedWorkoutTitle, contains('Cramp-Relief'));
      expect(readiness.explanations.any((e) => e.factorName.contains('Menstrual')), true);
    });

    test('3. Female Safety & Available Time: Quick Indoor Home Routine switch (Zero Equipment)', () {
      final checkin = DailyCheckin.defaultToday(userId: 'test_user').copyWith(
        notes: 'indoor',
      );

      final readiness = readinessEngine.calculate(checkin: checkin);
      final target = scalingEngine.scale(
        userId: 'test_user',
        readiness: readiness,
        checkin: checkin,
      );

      expect(target.suggestedWorkoutTitle, contains('Zero Equipment'));
    });

    test('4. Exam Day + Low Sleep + High Stress drops target to ~30-55% (No-Guilt Scaling)', () {
      final examCheckin = DailyCheckin.defaultToday(userId: 'test_user').copyWith(
        isExamDay: true,
        sleepHours: 4.0,
        stressLevel: 5,
        mood: MoodEmoji.exhausted,
      );

      final readiness = readinessEngine.calculate(checkin: examCheckin);
      final target = scalingEngine.scale(
        userId: 'test_user',
        readiness: readiness,
        checkin: examCheckin,
      );

      expect(readiness.score, lessThan(45));
      expect(target.scalingPercentage, lessThanOrEqualTo(55));
      expect(target.suggestedWorkoutId, 'quick_15_calm_mobility');
    });

    test('5. AI Notification Booster includes Tanglish motivational messages', () {
      final message = NotificationTemplates.getMessage(
        context: 'anti_robot',
        tone: NotificationTone.friendly,
      );

      expect(message, contains('Level 3 kashtam-ah irundhucha? Don\'t worry, robo maari force panna maatom'));
    });
  });
}

