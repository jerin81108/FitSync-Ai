import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/injury.dart';
import '../../../core/widgets/glass_card.dart';
import '../injury_controller.dart';

/// 2-Tap Injury Guard Modal
class InjuryGuardModal extends ConsumerStatefulWidget {
  const InjuryGuardModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InjuryGuardModal(),
    );
  }

  @override
  ConsumerState<InjuryGuardModal> createState() => _InjuryGuardModalState();
}

class _InjuryGuardModalState extends ConsumerState<InjuryGuardModal> {
  BodyArea _selectedArea = BodyArea.knee;
  InjurySeverity _selectedSeverity = InjurySeverity.moderate;
  int _recoveryDays = 7;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = ref.read(injuryControllerProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Injury Guard (2 Taps)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Offload pain points instantly. Never push through injury.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // 1. Pick Body Area (Tap 1)
                const Text('1. Tap Injured Body Area', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BodyArea.values.map((area) {
                    final isSelected = _selectedArea == area;
                    return ChoiceChip(
                      avatar: Text(area.emoji),
                      label: Text(area.label),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedArea = area);
                      },
                      selectedColor: AppColors.warmCoral.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.warmCoral : null,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 2. Pick Severity (Tap 2)
                const Text('2. Tap Pain Severity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: InjurySeverity.values.map((sev) {
                    final isSelected = _selectedSeverity == sev;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GlassCard(
                          onTap: () => setState(() => _selectedSeverity = sev),
                          backgroundColor: isSelected ? AppColors.warmCoral.withValues(alpha: 0.12) : null,
                          border: BorderSide(
                            color: isSelected ? AppColors.warmCoral : Colors.transparent,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            children: [
                              Text(
                                sev.label,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? AppColors.warmCoral : null,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '-${sev.penaltyPoints.round()} pts',
                                style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 3. Expected Recovery Days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expected Recovery Time', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      '$_recoveryDays days',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deepTeal),
                    ),
                  ],
                ),
                Slider(
                  value: _recoveryDays.toDouble(),
                  min: 1,
                  max: 21,
                  divisions: 20,
                  activeColor: AppColors.deepTeal,
                  onChanged: (val) => setState(() => _recoveryDays = val.round()),
                ),
                const SizedBox(height: 12),

                // Non-Negotiable Medical Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 20, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'FitSync AI is not a medical service. If pain is severe or persistent, see a doctor. We do not diagnose.',
                          style: TextStyle(fontSize: 11, height: 1.35, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Activate Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                controller.logInjury(
                  bodyArea: _selectedArea,
                  severity: _selectedSeverity,
                  expectedRecoveryDays: _recoveryDays,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.warmCoral),
              child: const Text('Activate Injury Guard'),
            ),
          ),
        ],
      ),
    );
  }
}
