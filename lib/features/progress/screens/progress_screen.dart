import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/mindset_wisdom.dart';
import '../../../core/models/badge.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mindset_background.dart';
import '../../../core/widgets/mindset_reset_modal.dart';
import '../../streaks/streak_controller.dart';

/// Comprehensive Progress Screen with weekly trends, streaks, and guilt-free badges
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakState = ref.watch(streakControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MindsetBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Weekly Progress & Badges'),
          actions: [
            IconButton(
              tooltip: 'Mindset Theme',
              icon: const Icon(Icons.palette_outlined),
              onPressed: () => MindsetBackground.showThemePicker(context),
            ),
            IconButton(
              tooltip: '1-Min Mindset Reset',
              icon: const Text('🧘', style: TextStyle(fontSize: 20)),
              onPressed: () => MindsetResetModal.show(context),
            ),
          ],
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
            const SizedBox(height: 28),

            // 6. Mental Resilience & Growth Mindset Evolution (Mindset Enhancement)
            _buildMentalResilienceShelf(context, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildMentalResilienceShelf(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text('🧠', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Mental Resilience & Growth Mindset',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => MindsetResetModal.show(context),
              child: const Text('🧘 Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepTeal)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'True fitness is psychological freedom from shame, burnout, and comparison.',
          style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
        const SizedBox(height: 12),
        ...MindsetWisdom.mentalResilienceMilestones.map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF7FAF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.deepTeal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(m.emoji, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Mastered', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.green)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.milestone,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepTeal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.mindsetLesson,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStreakHero(dynamic streakState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C5C), Color(0xFF1B6B80), Color(0xFF2EC4B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C5C).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🔥', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${streakState.streak.currentStreak} Day Flex Streak',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '⚡ 100% Guilt-Free Shield Active',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  '🛡️ ${streakState.streak.streakFreezesLeft} Shields',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F4C5C)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroStat('Active Days', '${streakState.streak.totalActiveDays}'),
              _buildHeroStat('Rest Logged', '${streakState.streak.totalIntentionalRestDays}'),
              _buildHeroStat('Longest Run', '${streakState.streak.longestStreak} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85))),
      ],
    );
  }

  Widget _buildWeeklyStepsChart(bool isDark) {
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final stepsRatio = [0.45, 0.72, 0.35, 0.85, 1.0, 0.65, 0.9];
    final stepsValues = ['3.6k', '5.8k', '2.8k', '6.8k', '8.0k', '5.2k', '7.2k'];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('👟', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Weekly Step Adaptation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Avg 5,630 steps',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final ratio = stepsRatio[i];
                final isToday = i == 4;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      stepsValues[i],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isToday ? AppColors.warmCoral : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: (ratio * 75).clamp(18.0, 75.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [const Color(0xFFFF5722), const Color(0xFFFF8A65)]
                              : [const Color(0xFF0F4C5C), const Color(0xFF2EC4B6)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (isToday ? AppColors.warmCoral : AppColors.deepTeal).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🌙', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Sleep & Rest Recovery', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mintAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Target: 7.5h', style: TextStyle(fontSize: 11, color: AppColors.deepTeal, fontWeight: FontWeight.w700)),
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
                final hrs = sleepHours[i];
                final isShort = hrs < 6.0;
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
                      width: 26,
                      height: (hrs / 10.0 * 65).clamp(16.0, 65.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isShort
                              ? [const Color(0xFFFF5252), const Color(0xFFFF7A7A)]
                              : [const Color(0xFF2EC4B6), const Color(0xFF64DFDF)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.all(16),
      backgroundColor: isUnlocked
          ? (isDark ? AppColors.darkCard : Colors.white)
          : (isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8F9FA)),
      border: BorderSide(
        color: isUnlocked ? AppColors.mintAccent.withValues(alpha: 0.5) : Colors.transparent,
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? AppColors.mintAccent.withValues(alpha: 0.15)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                ),
                child: Center(
                  child: Text(badge.iconEmoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.mintAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 12, color: AppColors.deepTeal),
                      SizedBox(width: 2),
                      Text('UNLOCKED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.deepTeal)),
                    ],
                  ),
                )
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
                  fontWeight: FontWeight.w800,
                  color: isUnlocked ? null : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badge.description,
                maxLines: 2,
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
