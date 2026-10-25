import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/local_storage_service.dart';
import 'core/storage/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first local storage
  final storage = LocalStorageService();
  await storage.init();

  // Initialize Supabase (with graceful offline fallback)
  await SupabaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
      ],
      child: const FitSyncApp(),
    ),
  );
}

class FitSyncApp extends ConsumerWidget {
  const FitSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(localStorageProvider);
    final bool hasCompletedOnboarding = storage.isOnboardingCompleted();

    return MaterialApp(
      title: 'FitSync AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: hasCompletedOnboarding
          ? const MainNavigationScreen()
          : OnboardingScreen(
              onCompleted: () {
                // Navigates directly into main app once onboarding concludes
                runApp(
                  ProviderScope(
                    overrides: [
                      localStorageProvider.overrideWithValue(storage),
                    ],
                    child: const MaterialApp(
                      title: 'FitSync AI',
                      debugShowCheckedModeBanner: false,
                      home: MainNavigationScreen(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
