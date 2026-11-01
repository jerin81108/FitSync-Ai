import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/female_health_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../female_health_controller.dart';

/// Female Health Sync Engine Modal
/// Page 4 & 5 of FitSync AI Spec:
/// 1. Menstrual Cycle & Period Tracking (Day 1-3 automatic target reduction, cramp-relief yoga)
/// 2. Hormonal Shifts & Energy Swings (PCOS/PCOD balance mode)
/// 3. Safety & Available Time (Indoor Home-Workout zero equipment vs Outdoor)
class FemaleHealthModal extends ConsumerWidget {
  const FemaleHealthModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FemaleHealthModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(femaleHealthControllerProvider);
    final controller = ref.read(femaleHealthControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warmCoral.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌸', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Female Health Sync Engine',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cycle Sync • PCOS Balance • Safety-Aware Routines',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // 1. Enable Cycle Sync Switch
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('🩸', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Enable Cycle & Period Sync', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(
                              'Auto-adapts targets during low-energy days & cramps',
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.isCycleTrackingEnabled,
                        onChanged: (val) => controller.toggleCycleTracking(val),
                        activeThumbColor: AppColors.warmCoral,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Cycle Phase Selector (if enabled)
                if (state.isCycleTrackingEnabled) ...[
                  const Text('Select Today’s Cycle Phase', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  Column(
                    children: CyclePhase.values.map((phase) {
                      final isSelected = state.currentPhase == phase;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => controller.setPhase(phase),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.warmCoral.withValues(alpha: 0.12)
                                  : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.warmCoral : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(phase.emoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        phase.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: isSelected ? AppColors.warmCoral : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        phase.description,
                                        style: TextStyle(
                                          fontSize: 11,
                                          height: 1.3,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded, color: AppColors.warmCoral, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. PCOS / PCOD Hormonal Balance Mode
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('🧘‍♀️', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PCOS / PCOD Balance Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(
                              'Prevents cortisol spikes by swapping high-intensity with restorative hormonal-safe movement.',
                              style: TextStyle(fontSize: 11, height: 1.3, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.isPcosPcodMode,
                        onChanged: (val) => controller.togglePcosMode(val),
                        activeThumbColor: AppColors.deepTeal,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Safety & Time Aware: Indoor vs Outdoor Workout
                const Text('Workout Setting & Safety Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Late study night or dark outside? Switch to Indoor for a rapid 15-min zero-equipment home routine.',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: WorkoutEnvironment.values.map((env) {
                    final isSelected = state.workoutEnvironment == env;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => controller.setEnvironment(env),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.deepTeal.withValues(alpha: 0.15)
                                  : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F3F5)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.deepTeal : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  env == WorkoutEnvironment.indoor ? '🏠 Indoor' : '🌳 Outdoor',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? AppColors.deepTeal : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  env == WorkoutEnvironment.indoor ? 'Home / No Gear' : 'Park / Jogging',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Save & Calibrate Target'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

