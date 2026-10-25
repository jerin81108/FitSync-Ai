import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync_ai/core/models/calendar_event.dart';
import 'package:fitsync_ai/core/models/injury.dart';
import 'package:fitsync_ai/core/models/notification_settings.dart';
import 'package:fitsync_ai/core/storage/local_storage_service.dart';
import 'package:fitsync_ai/features/auth/auth_controller.dart';
import 'package:fitsync_ai/features/health/health_sync_service.dart';
import 'package:fitsync_ai/features/injury/injury_controller.dart';
import 'package:fitsync_ai/features/notifications/notification_templates.dart';
import 'package:fitsync_ai/features/progress/screens/progress_screen.dart';
import 'package:fitsync_ai/features/schedule/schedule_sync_service.dart';
import 'package:fitsync_ai/features/schedule/screens/schedule_screen.dart';
import 'package:fitsync_ai/features/workouts/workout_library.dart';

void main() {
  group('Phase 2: Health Sync, Schedule Sync, Injury Guard, & Notifications', () {
    // -------------------------------------------------------------------------
    // 1. HEALTH SYNC TESTS
    // -------------------------------------------------------------------------
    test('Health Sync Service returns fallback and respects manual entry', () async {
      final service = HealthSyncService();
      final snapshot = await service.fetchTodaySnapshot();

      expect(snapshot.stepsToday, greaterThan(0));
      expect(snapshot.sleepDurationHours, greaterThan(0));

      final manual = snapshot.copyWith(sleepDurationHours: 8.5, stepsToday: 8200);
      final syncedManual = await service.fetchTodaySnapshot(manualOverride: manual);

      expect(syncedManual.sleepDurationHours, equals(8.5));
      expect(syncedManual.stepsToday, equals(8200));
      expect(syncedManual.sourceName, equals('Manual Entry'));
    });

    // -------------------------------------------------------------------------
    // 2. SCHEDULE SYNC & KEYWORD DETECTION TESTS
    // -------------------------------------------------------------------------
    test('ScheduleSyncService keyword detection classifies life loads accurately', () {
      final exam = ScheduleSyncService.detectLoad('Final Term Exam in CS101');
      expect(exam.level, equals(EventLoadLevel.exam));
      expect(exam.isExam, isTrue);

      final viva = ScheduleSyncService.detectLoad('Physics Lab Viva & Test');
      expect(viva.level, equals(EventLoadLevel.exam));
      expect(viva.isExam, isTrue);

      final deadline = ScheduleSyncService.detectLoad('Project Submission Deadline');
      expect(deadline.level, equals(EventLoadLevel.heavy));
      expect(deadline.isExam, isFalse);

      final interview = ScheduleSyncService.detectLoad('Internship Technical Interview');
      expect(interview.level, equals(EventLoadLevel.heavy));

      final lab = ScheduleSyncService.detectLoad('Chemistry Lab Workshop');
      expect(lab.level, equals(EventLoadLevel.medium));

      final casual = ScheduleSyncService.detectLoad('Evening Walk & Free Time');
      expect(casual.level, equals(EventLoadLevel.light));
    });

    // -------------------------------------------------------------------------
    // 3. INJURY GUARD & FILTER TESTS
    // -------------------------------------------------------------------------
    test('Injury Guard offloads injured zones and recovers in 1 tap', () {
      final container = ProviderContainer();
      final injuryController = container.read(injuryControllerProvider.notifier);

      // Log knee injury
      injuryController.logInjury(
        bodyArea: BodyArea.knee,
        severity: InjurySeverity.moderate,
        expectedRecoveryDays: 7,
      );

      final state = container.read(injuryControllerProvider);
      expect(state.hasActiveInjury, isTrue);
      expect(state.activeInjury!.bodyArea, equals(BodyArea.knee));

      // Filtered workout list excludes heavy lower body routines
      final filteredWorkouts = WorkoutLibrary.filterForInjury(
        workouts: WorkoutLibrary.allWorkouts,
        injuredBodyArea: 'knee',
      );
      expect(filteredWorkouts.any((w) => w.id == 'lower_body_leg_burn'), isFalse);

      // 1-tap mark recovered
      injuryController.markRecovered();
      final recoveredState = container.read(injuryControllerProvider);
      expect(recoveredState.hasActiveInjury, isFalse);
    });

    test('Shoulder injury strictly excludes upper body pressing', () {
      final filtered = WorkoutLibrary.filterForInjury(
        workouts: WorkoutLibrary.allWorkouts,
        injuredBodyArea: 'shoulder',
      );

      for (final w in filtered) {
        expect(w.bodyRegion == 'upper_body', isFalse);
      }
    });

    // -------------------------------------------------------------------------
    // 4. NOTIFICATION TEMPLATE REPOSITORY TESTS
    // -------------------------------------------------------------------------
    test('Notification Templates provide tone-appropriate, non-shaming copy', () {
      final examFriendly = NotificationTemplates.getMessage(
        context: 'exam_day',
        tone: NotificationTone.friendly,
      );
      expect(examFriendly, contains('Exam week is heavy'));
      expect(examFriendly, contains('streak'));

      final lowSleepCalm = NotificationTemplates.getMessage(
        context: 'low_sleep',
        tone: NotificationTone.calm,
      );
      expect(lowSleepCalm, contains('Honor your fatigue'));

      final highStressPlayful = NotificationTemplates.getMessage(
        context: 'high_stress',
        tone: NotificationTone.playful,
      );
      expect(highStressPlayful, contains('Stress monster'));
    });

    // -------------------------------------------------------------------------
    // 5. WIDGET TESTS: SCHEDULE & PROGRESS SCREENS
    // -------------------------------------------------------------------------
    testWidgets('ScheduleScreen renders week strip, keywords, and override chips', (tester) async {
      final storage = LocalStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: ScheduleScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Schedule & Life Load'), findsOneWidget);
      expect(find.text('Google Calendar (Read-Only)'), findsOneWidget);
      expect(find.text('Week-Ahead Load Forecast'), findsOneWidget);
      expect(find.text('Exam Day'), findsWidgets);
      expect(find.text('Heavy Day'), findsWidgets);
      expect(find.text('Free Day'), findsWidgets);
    });

    testWidgets('ProgressScreen renders flex streak, weekly trends, and badges', (tester) async {
      final storage = LocalStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: ProgressScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Weekly Progress & Badges'), findsOneWidget);
      expect(find.textContaining('Day Flex Streak'), findsOneWidget);
      expect(find.text('Weekly Step Adaptation'), findsOneWidget);
      expect(find.text('Sleep & Rest Recovery'), findsOneWidget);
      expect(find.text('Weekly Coach Insight'), findsOneWidget);
      expect(find.text('Badges & Milestones'), findsOneWidget);
      expect(find.text('Exam Warrior'), findsOneWidget);
      expect(find.text('Showed Up Tired'), findsOneWidget);
    });
  });
}
