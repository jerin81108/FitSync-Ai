import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../injury_controller.dart';
import '../screens/injury_guard_modal.dart';

/// Active Injury Guard Banner displayed on Home and Workout screens
class ActiveInjuryBanner extends ConsumerWidget {
  const ActiveInjuryBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final injuryState = ref.watch(injuryControllerProvider);
    final injuryController = ref.read(injuryControllerProvider.notifier);
    final activeInjury = injuryState.activeInjury;

    if (activeInjury == null || !activeInjury.isActive) {
      // Optional button to log an injury
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: OutlinedButton.icon(
          onPressed: () => InjuryGuardModal.show(context),
          icon: const Icon(Icons.shield_outlined, size: 18, color: AppColors.deepTeal),
          label: const Text('Log An Injury Guard (Offload affected muscles)', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            side: BorderSide(color: AppColors.deepTeal.withValues(alpha: 0.3)),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        backgroundColor: AppColors.warmCoral.withValues(alpha: 0.08),
        border: BorderSide(color: AppColors.warmCoral.withValues(alpha: 0.3)),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(activeInjury.bodyArea.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Injury Guard Active: ${activeInjury.bodyArea.label} (${activeInjury.severity.label})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmCoral,
                        ),
                      ),
                      Text(
                        '${activeInjury.daysRemaining} days recovery remaining',
                        style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => injuryController.markRecovered(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.mintAccent.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    'Mark Recovered',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mintAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${activeInjury.bodyArea.affectedExercisesNote}. Workouts have been adjusted automatically.',
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
