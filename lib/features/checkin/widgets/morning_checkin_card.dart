import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/daily_checkin.dart';
import '../../../core/widgets/glass_card.dart';
import '../../readiness/readiness_controller.dart';

/// 10-second Morning Check-in Card
/// Quick mood selector, stress slider, sleep metrics, and heavy/exam day flags.
class MorningCheckinCard extends ConsumerStatefulWidget {
  const MorningCheckinCard({super.key});

  @override
  ConsumerState<MorningCheckinCard> createState() => _MorningCheckinCardState();
}

class _MorningCheckinCardState extends ConsumerState<MorningCheckinCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final readinessState = ref.watch(readinessControllerProvider);
    final controller = ref.read(readinessControllerProvider.notifier);
    final checkin = readinessState.checkin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.deepTeal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('☀️', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning Check-In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Takes 10 seconds to calibrate today',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.deepTeal,
                ),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Mood Emoji Selector (Always visible)
          const Text(
            'How are you feeling right now?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: MoodEmoji.values.map((mood) {
              final isSelected = checkin.mood == mood;
              return GestureDetector(
                onTap: () => controller.updateCheckin(mood: mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.deepTeal.withValues(alpha: 0.15)
                        : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F3F5)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.deepTeal : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.deepTeal : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Expanded section: Stress, Sleep, Exam toggle
          if (_isExpanded) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Stress Slider (1 to 5)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stress Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  _getStressLabel(checkin.stressLevel),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.warmCoral),
                ),
              ],
            ),
            Slider(
              value: checkin.stressLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: AppColors.warmCoral,
              onChanged: (val) => controller.updateCheckin(stressLevel: val.round()),
            ),

            // Sleep Hours Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sleep Duration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  '${checkin.sleepHours} hrs',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deepTeal),
                ),
              ],
            ),
            Slider(
              value: checkin.sleepHours,
              min: 3.0,
              max: 10.0,
              divisions: 14, // 0.5 hr increments
              activeColor: AppColors.deepTeal,
              onChanged: (val) => controller.updateCheckin(sleepHours: val),
            ),

            // Heavy Day & Exam Day Quick Toggles
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🎓 Exam Day'),
                    selected: checkin.isExamDay,
                    onSelected: (_) => controller.toggleExamDay(),
                    selectedColor: AppColors.loadExam.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: checkin.isExamDay ? AppColors.loadExam : AppColors.lightTextSecondary,
                      fontWeight: checkin.isExamDay ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('📅 Heavy Day'),
                    selected: checkin.isHeavyDay,
                    onSelected: (_) => controller.toggleHeavyDay(),
                    selectedColor: AppColors.warmCoral.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: checkin.isHeavyDay ? AppColors.warmCoral : AppColors.lightTextSecondary,
                      fontWeight: checkin.isHeavyDay ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🌸 Period (Day 1-3)'),
                    selected: checkin.cyclePhase?.toLowerCase() == 'menstrual',
                    onSelected: (val) {
                      controller.updateCheckin(
                        cyclePhase: val ? 'menstrual' : null,
                      );
                    },
                    selectedColor: AppColors.warmCoral.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: checkin.cyclePhase?.toLowerCase() == 'menstrual'
                          ? AppColors.warmCoral
                          : AppColors.lightTextSecondary,
                      fontWeight: checkin.cyclePhase?.toLowerCase() == 'menstrual'
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🏠 Home Indoor (No Gear)'),
                    selected: checkin.notes == 'indoor',
                    onSelected: (val) {
                      controller.updateCheckin(
                        notes: val ? 'indoor' : null,
                      );
                    },
                    selectedColor: AppColors.deepTeal.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: checkin.notes == 'indoor'
                          ? AppColors.deepTeal
                          : AppColors.lightTextSecondary,
                      fontWeight: checkin.notes == 'indoor'
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getStressLabel(int level) {
    switch (level) {
      case 1:
        return 'Zen (1/5)';
      case 2:
        return 'Low (2/5)';
      case 3:
        return 'Moderate (3/5)';
      case 4:
        return 'High (4/5)';
      case 5:
        return 'Overwhelmed (5/5)';
      default:
        return '$level/5';
    }
  }
}
