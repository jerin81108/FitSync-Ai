import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/badge.dart';
import '../../../core/widgets/glass_card.dart';
import '../../streaks/streak_controller.dart';

/// Comprehensive Progress Screen with weekly trends, streaks, and guilt-free badges
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakState = ref.watch(streakControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Weekly Progress & Badges'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // 1. Flex Streak Hero Banner
            _buildStreakHero(streakState, isDark),
            const SizedBox(height: 20),

            // 2. Weekly Steps & Active Minutes Chart
            _buildWeeklyStepsChart(isDark),
            const SizedBox(height: 20),

            // 3. Weekly Sleep & Readiness Trends
            _buildWeeklySleepTrend(isDark),
            const SizedBox(height: 20),

            // 4. Weekly Coach Summary Card
            GlassCard(
              backgroundColor: AppColors.deepTeal.withValues(alpha: 0.08),
              border: BorderSide(color: AppColors.deepTeal.withValues(alpha: 0.2)),
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Coach Insight',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deepTeal),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You balanced heavy exam loads with intentional rest and adapted workouts. Your streak is completely safe. Zero guilt, 100% resilience.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Badges Gallery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Badges & Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(
                  '${streakState.badges.where((b) => b.isUnlocked).length} of ${streakState.badges.length} unlocked',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemCount: streakState.badges.length,
              itemBuilder: (context, index) {
                final badge = streakState.badges[index];
                return _buildBadgeCard(badge, isDark);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStreakHero(dynamic streakState, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.warmCoral.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🔥', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${streakState.streak.currentStreak} Day Flex Streak',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const Text(
                        'Active & Protected',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mintAccent),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.mintAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🛡️ ${streakState.streak.streakFreezesLeft} Shields',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mintAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Active Days', '${streakState.streak.totalActiveDays}'),
              _buildStatItem('Rest Logged', '${streakState.streak.totalIntentionalRestDays}'),
              _buildStatItem('Longest Run', '${streakState.streak.longestStreak} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
      ],
    );
  }

  Widget _buildWeeklyStepsChart(bool isDark) {
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final stepsRatio = [0.4, 0.7, 0.3, 0.8, 1.0, 0.6, 0.9]; // Sample 7-day ratio

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Step Adaptation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(
                'Avg 5,840 steps',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio = stepsRatio[i];
                final isToday = i == 4; // Friday sample today
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: (ratio * 80).clamp(16.0, 80.0),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.warmCoral : AppColors.deepTeal.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weekDays[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday ? AppColors.warmCoral : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySleepTrend(bool isDark) {
    final sleepDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final sleepHours = [6.5, 5.0, 4.5, 7.5, 8.0, 7.0, 8.5]; // Low on exam Wed

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sleep & Rest Recovery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Target: 7.5h', style: TextStyle(fontSize: 12, color: AppColors.deepTeal, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final hrs = sleepHours[i];
                final isShort = hrs < 5.5;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${hrs}h',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isShort ? AppColors.warmCoral : AppColors.deepTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: (hrs / 10.0 * 65).clamp(14.0, 65.0),
                      decoration: BoxDecoration(
                        color: isShort ? AppColors.warmCoral.withValues(alpha: 0.7) : AppColors.mintAccent.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(sleepDays[i], style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(AppBadge badge, bool isDark) {
    final isUnlocked = badge.isUnlocked;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isUnlocked
          ? (isDark ? AppColors.darkCard : Colors.white)
          : (isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8F9FA)),
      border: BorderSide(
        color: isUnlocked ? AppColors.mintAccent.withValues(alpha: 0.4) : Colors.transparent,
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(badge.iconEmoji, style: const TextStyle(fontSize: 32)),
              if (isUnlocked)
                const Icon(Icons.check_circle_rounded, color: AppColors.mintAccent, size: 20)
              else
                const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isUnlocked ? null : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badge.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
