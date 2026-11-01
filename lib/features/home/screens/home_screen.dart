import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/daily_target.dart';
import '../../../core/models/workout.dart';
import '../../../core/widgets/animated_readiness_ring.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/why_target_bottom_sheet.dart';
import '../../auth/auth_controller.dart';
import '../../checkin/widgets/morning_checkin_card.dart';
import '../../female_health/female_health_controller.dart';
import '../../female_health/widgets/female_health_modal.dart';
import '../../injury/screens/injury_guard_modal.dart';
import '../../injury/widgets/active_injury_banner.dart';
import '../../monetization/widgets/context_recommendation_card.dart';
import '../../monetization/widgets/premium_plan_modal.dart';
import '../../notifications/notification_controller.dart';
import '../../notifications/notification_templates.dart';
import '../../progression/anti_robot_controller.dart';
import '../../readiness/readiness_controller.dart';
import '../../scaling/target_controller.dart';
import '../../streaks/streak_controller.dart';
import '../../workouts/workout_library.dart';

/// FitSync AI Home Dashboard
/// Houses the animated Readiness Ring, adapted targets, week load strip, and quick check-in.
class HomeScreen extends ConsumerWidget {
  final void Function(Workout workout)? onStartWorkout;

  const HomeScreen({super.key, this.onStartWorkout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final readinessState = ref.watch(readinessControllerProvider);
    final target = ref.watch(targetControllerProvider);
    final streakState = ref.watch(streakControllerProvider);
    final femaleHealth = ref.watch(femaleHealthControllerProvider);
    final antiRobot = ref.watch(antiRobotControllerProvider);
    final notifController = ref.read(notificationControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = auth.user?.name ?? 'Athlete';
    final readiness = readinessState.readiness;
    final ringColor = AppColors.getReadinessColor(readiness.score);

    // Find suggested workout object
    final suggestedWorkout = WorkoutLibrary.findById(target.suggestedWorkoutId);

    // Determine today's AI Coach message context
    String coachContext = 'regular_morning';
    if (readinessState.checkin.isExamDay) {
      coachContext = 'exam_day';
    } else if (readinessState.checkin.cyclePhase?.toLowerCase() == 'menstrual') {
      coachContext = 'cycle_menstrual';
    } else if (antiRobot.isConsolidating) {
      coachContext = 'anti_robot';
    } else if (readinessState.checkin.sleepHours < 5.5) {
      coachContext = 'low_sleep';
    } else if (readinessState.checkin.stressLevel >= 4) {
      coachContext = 'high_stress';
    } else if (target.isPushDay) {
      coachContext = 'push_day';
    } else if (target.isIntentionalRestDay) {
      coachContext = 'rest_day';
    }
    final coachMessage = NotificationTemplates.getMessage(
      context: coachContext,
      tone: ref.watch(notificationControllerProvider).tone,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row (Greeting & Streak Flame)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Streak Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warmCoral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warmCoral.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${streakState.streak.currentStreak}d Flex',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warmCoral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Quick Life-Sync Action Strip (Female Health, Anti-Robot Level, Premium ₹99)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Female Health Sync Pill
                    GestureDetector(
                      onTap: () => FemaleHealthModal.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: femaleHealth.isCycleTrackingEnabled
                              ? AppColors.warmCoral.withValues(alpha: 0.14)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: femaleHealth.isCycleTrackingEnabled ? AppColors.warmCoral : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🌸', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              femaleHealth.isCycleTrackingEnabled
                                  ? 'Cycle: ${femaleHealth.currentPhase.label.split(' ').first}'
                                  : 'Female Health Sync',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: femaleHealth.isCycleTrackingEnabled ? AppColors.warmCoral : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Anti-Robot Level Pill
                    GestureDetector(
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                            title: const Row(
                              children: [
                                Text('🤖 Anti-Robot Progression'),
                              ],
                            ),
                            content: Text(
                              'Current: ${antiRobot.levelTitle}\n\n${antiRobot.coachNote}\n\nNormal apps force users into higher levels without checking fatigue. FitSync AI checks how hard it felt and consolidates stamina before jumping to the next level.',
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Got It'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: antiRobot.isConsolidating
                              ? AppColors.mintAccent.withValues(alpha: 0.15)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: antiRobot.isConsolidating ? AppColors.mintAccent : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🤖', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              antiRobot.isConsolidating
                                  ? 'Level ${antiRobot.currentLevel} (Consolidating)'
                                  : 'Level ${antiRobot.currentLevel}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: antiRobot.isConsolidating ? AppColors.deepTeal : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Premium ₹99/mo Pill
                    GestureDetector(
                      onTap: () => PremiumPlanModal.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.deepTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('💎', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              'Premium ₹99/mo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. AI Motivational Coach Card (Page 3 - LLM Booster)
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.deepTeal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('💬', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'AI Coach Daily Whisper',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepTeal),
                              ),
                              Text(
                                'Life-Aware LLM',
                                style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"$coachMessage"',
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Active Injury Banner (if injury guard active)
              const ActiveInjuryBanner(),

              // 5. Week-Ahead Load Strip
              _buildWeekLoadStrip(context, ref, isDark),
              const SizedBox(height: 24),

              // 3. Central Animated Readiness Ring Card
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    AnimatedReadinessRing(
                      score: readiness.score,
                      band: readiness.band,
                      size: 210,
                      onTap: () => WhyTargetBottomSheet.show(context, readiness),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: () => WhyTargetBottomSheet.show(context, readiness),
                      icon: const Icon(Icons.info_outline, size: 16, color: AppColors.deepTeal),
                      label: const Text(
                        'Why is my target this? →',
                        style: TextStyle(
                          color: AppColors.deepTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Today's Adapted Target Card
              _buildAdaptedTargetCard(context, ref, target, suggestedWorkout, ringColor, isDark),
              const SizedBox(height: 20),

              // 5. Morning Check-in Card (10-second check-in)
              const MorningCheckinCard(),
              const SizedBox(height: 20),

              // 6. No-Guilt Flex Streak Summary Card
              _buildStreakSummaryCard(context, ref, streakState, isDark),
              const SizedBox(height: 20),

              // 7. Context-Based Wellness Recommendation (Pages 7 & 8)
              const ContextRecommendationCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- Week-Ahead Load Strip ---
  Widget _buildWeekLoadStrip(BuildContext context, WidgetRef ref, bool isDark) {
    final readinessController = ref.read(readinessControllerProvider.notifier);
    final checkin = ref.watch(readinessControllerProvider).checkin;
    final now = DateTime.now();

    final days = List.generate(7, (i) => now.add(Duration(days: i - now.weekday + 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Week Ahead Load',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              'Tap day to mark heavy',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final isToday = day.day == now.day && day.month == now.month;
            final isExam = isToday && checkin.isExamDay;
            final isHeavy = isToday && checkin.isHeavyDay;

            Color dotColor = AppColors.loadLight;
            if (isExam) {
              dotColor = AppColors.loadExam;
            } else if (isHeavy) {
              dotColor = AppColors.loadHeavy;
            }

            return Expanded(
              child: GestureDetector(
                onTap: isToday ? () => readinessController.toggleHeavyDay() : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.deepTeal.withValues(alpha: 0.12)
                        : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isToday ? AppColors.deepTeal : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day)[0],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isToday ? AppColors.deepTeal : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Adapted Target Card ---
  Widget _buildAdaptedTargetCard(
    BuildContext context,
    WidgetRef ref,
    DailyTarget target,
    Workout workout,
    Color ringColor,
    bool isDark,
  ) {
    final targetController = ref.read(targetControllerProvider.notifier);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ringColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${target.scalingPercentage}% Load Target',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ringColor,
                      ),
                    ),
                  ),
                  if (target.isPushDay) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warmCoral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '🚀 Push Day',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmCoral,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (target.isIntentionalRestDay)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '🛡️ Rest Logged',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mintAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Steps & Active Minutes Metrics
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adapted Steps',
                        style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${target.adaptedSteps}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Minutes',
                        style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${target.adaptedActiveMinutes} min',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Suggested Workout Routine Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Suggested Routine',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.deepTeal),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        workout.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${workout.durationMinutes} min • Intensity ${workout.intensity}/5 • ${workout.equipment}',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Target Adjustment Buttons ("Make it easier / Make it harder")
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => targetController.makeEasier(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Make easier', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => targetController.makeHarder(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Make harder', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary Actions: "Start Workout" or "Log Intentional Rest"
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (onStartWorkout != null) {
                      onStartWorkout!(workout);
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text('Start Routine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () => targetController.logIntentionalRest(),
                  icon: const Icon(Icons.hotel_rounded, size: 18),
                  label: const Text('Rest Day', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warmCoral,
                    side: const BorderSide(color: AppColors.warmCoral),
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Streak Summary Card ---
  Widget _buildStreakSummaryCard(
    BuildContext context,
    WidgetRef ref,
    StreakState streakState,
    bool isDark,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🛡️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'No-Guilt Flex Streak',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mintAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${streakState.streak.streakFreezesLeft} Shields Left',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            streakState.latestCheerMessage ??
                'Rest on exam or heavy days NEVER breaks your streak. Your progress is safeguarded.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakMetric('Active Days', '${streakState.streak.totalActiveDays}'),
              _buildStreakMetric('Rest Logged', '${streakState.streak.totalIntentionalRestDays}'),
              _buildStreakMetric('Longest', '${streakState.streak.longestStreak} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }
}
