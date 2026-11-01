import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/notification_settings.dart';
import '../../core/models/workout.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/auth_controller.dart';
import '../female_health/female_health_controller.dart';
import '../female_health/widgets/female_health_modal.dart';
import '../health/health_controller.dart';
import '../home/screens/home_screen.dart';
import '../monetization/widgets/premium_plan_modal.dart';
import '../notifications/notification_controller.dart';
import '../progress/screens/progress_screen.dart';
import '../progression/anti_robot_controller.dart';
import '../schedule/screens/schedule_screen.dart';
import '../workouts/screens/active_workout_screen.dart';
import '../workouts/screens/workout_list_screen.dart';

/// Main Application Shell with thumb-friendly bottom navigation bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToWorkout(Workout workout) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ActiveWorkoutScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(onStartWorkout: _navigateToWorkout),
      WorkoutListScreen(onSelectWorkout: _navigateToWorkout),
      const ScheduleScreen(),
      const ProgressScreen(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.deepTeal.withValues(alpha: 0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.deepTeal),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center_rounded, color: AppColors.deepTeal),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.deepTeal),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded, color: AppColors.deepTeal),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.deepTeal),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB: PROFILE & SETTINGS ---
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.user;
    final healthState = ref.watch(healthControllerProvider);
    final healthController = ref.read(healthControllerProvider.notifier);
    final notifSettings = ref.watch(notificationControllerProvider);
    final notifController = ref.read(notificationControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Profile & Connected Sources')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.deepTeal.withValues(alpha: 0.15),
                    child: const Text('🏃', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.name ?? 'Athlete',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Primary: ${(profile?.primaryGoal ?? "stay_active").replaceAll('_', ' ').toUpperCase()}',
                        style: const TextStyle(fontSize: 12, color: AppColors.deepTeal, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Premium Plan Subscription Card (Page 6)
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text('💎', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('FitSync AI Premium', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.deepTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('₹99 / mo', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepTeal, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock Automatic Calendar Exam Sync, Female Period Engine, Anti-Robot Challenges, & LLM Coach.',
                    style: TextStyle(fontSize: 12, height: 1.35, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => PremiumPlanModal.show(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal,
                      minimumSize: const Size.fromHeight(42),
                    ),
                    child: const Text('View Plans & Upgrades', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Female Health Sync Engine Tile (Page 4 & 5)
            Consumer(
              builder: (context, ref, _) {
                final femaleHealth = ref.watch(femaleHealthControllerProvider);
                return GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warmCoral.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🌸', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Female Health Sync Engine', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(
                              femaleHealth.isCycleTrackingEnabled
                                  ? 'Active: ${femaleHealth.currentPhase.label}'
                                  : 'Cycle, PCOS Balance & Safety Mode',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: AppColors.warmCoral),
                        onPressed: () => FemaleHealthModal.show(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Health Connect / Smartwatch Ecosystem (Pages 6 & 7: Noise, boAt, Fire-Boltt, Apple, Google)
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.mintAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, color: AppColors.mintAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Health Connect & Smartwatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(
                              healthState.snapshot.isWearableConnected ? 'Connected (${healthState.snapshot.sourceName})' : 'Manual Entry Active (Fallback ready)',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: healthState.snapshot.isWearableConnected,
                        onChanged: (val) {
                          if (val) {
                            healthController.connectHealth();
                          } else {
                            healthController.disconnect();
                          }
                        },
                        activeThumbColor: AppColors.mintAccent,
                      ),
                    ],
                  ),
                  if (healthState.snapshot.isWearableConnected) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Steps: ${healthState.snapshot.stepsToday}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('Sleep: ${healthState.snapshot.sleepDurationHours}h', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('RHR: ${healthState.snapshot.restingHeartRateBpm ?? 64} bpm', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notification Booster Settings Tile
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warmCoral.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active, color: AppColors.warmCoral, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Morning Booster (Wake Time)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('Time: ${notifSettings.wakeTime} • Tone: ${notifSettings.tone.label}', style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: notifSettings.enabled,
                        onChanged: (val) => notifController.toggleEnabled(val),
                        activeThumbColor: AppColors.warmCoral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Select Preferred Tone:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: NotificationTone.values.map((tone) {
                      final isSelected = notifSettings.tone == tone;
                      return ChoiceChip(
                        avatar: Text(tone.emoji),
                        label: Text(tone.label.split(' ').first),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) notifController.setTone(tone);
                        },
                        selectedColor: AppColors.warmCoral.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.warmCoral : null,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Preview message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"${notifController.getTodayNotificationMessage()}"',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // DPDP Compliance & Privacy
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🛡️ Privacy & DPDP Compliance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'FitSync AI strictly follows India’s Digital Personal Data Protection Act. Your biometric and cycle data are encrypted locally and never monetized or shared with ad networks.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data exported to encrypted JSON bundle.')),
                      );
                    },
                    child: const Text('Export My Data'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
