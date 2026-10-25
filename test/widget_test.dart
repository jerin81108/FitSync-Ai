import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync_ai/core/storage/local_storage_service.dart';
import 'package:fitsync_ai/features/auth/auth_controller.dart';
import 'package:fitsync_ai/features/home/screens/home_screen.dart';
import 'package:fitsync_ai/features/onboarding/screens/onboarding_screen.dart';

void main() {
  group('FitSync AI Widget Tests - Onboarding & Home Dashboard', () {
    testWidgets('OnboardingScreen renders initial welcome step correctly', (tester) async {
      final storage = LocalStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
          ],
          child: MaterialApp(
            home: OnboardingScreen(onCompleted: () {}),
          ),
        ),
      );

      // Verify Welcome step copy
      expect(find.text('FitSync AI'), findsOneWidget);
      expect(find.text('Fitness that fits your life.'), findsOneWidget);
      expect(find.text('Get Started (under 60s)'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.text('Get Started (under 60s)'));
      await tester.pumpAndSettle();

      // Verify Step 1: Goal picker
      expect(find.text('What is your main focus?'), findsOneWidget);
      expect(find.text('Stay Active'), findsOneWidget);
      expect(find.text('Reduce Stress'), findsOneWidget);
    });

    testWidgets('HomeScreen renders readiness ring and adapted target card', (tester) async {
      final storage = LocalStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Home Screen elements
      expect(find.textContaining('Flex'), findsWidgets);
      expect(find.text('Week Ahead Load'), findsOneWidget);
      expect(find.text('Why is my target this? →'), findsOneWidget);
      expect(find.text('Adapted Steps'), findsOneWidget);
      expect(find.text('Active Minutes'), findsOneWidget);
      expect(find.text('Morning Check-In'), findsOneWidget);
      expect(find.text('No-Guilt Flex Streak'), findsOneWidget);
    });
  });
}
