import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

/// Premium Plan & B2B Smartwatch Ecosystem Modal (Pages 6 & 7 of FitSync AI Spec)
/// Highlights:
/// - ₹99/mo (Quarterly) or ₹149/mo (Standard)
/// - Automatic Exam Calendar Sync
/// - Female Health & Cycle Tracking Engine
/// - Anti-Robot Challenge Adaptation
/// - Smartwatch Partnerships (Noise, boAt, Fire-Boltt, Apple, WearOS)
class PremiumPlanModal extends StatefulWidget {
  const PremiumPlanModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumPlanModal(),
    );
  }

  @override
  State<PremiumPlanModal> createState() => _PremiumPlanModalState();
}

class _PremiumPlanModalState extends State<PremiumPlanModal> {
  int _selectedTierIndex = 0; // 0: ₹99/mo (Annual/Quarterly), 1: ₹149/mo (Monthly)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
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
                    color: AppColors.deepTeal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('💎', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FitSync AI Premium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unlock Life-Aware Intelligence & AI Coaching',
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
                // Plan Options (₹99 vs ₹149)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTierIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _selectedTierIndex == 0
                                ? AppColors.deepTeal.withValues(alpha: 0.12)
                                : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedTierIndex == 0 ? AppColors.deepTeal : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warmCoral,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('₹99 / mo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text('Billed ₹297 quarterly', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTierIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _selectedTierIndex == 1
                                ? AppColors.deepTeal.withValues(alpha: 0.12)
                                : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedTierIndex == 1 ? AppColors.deepTeal : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.mintAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'FLEXIBLE',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.mintAccent),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('₹149 / mo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text('Cancel anytime', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Feature Comparison
                const Text('What You Unlock with Premium:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 10),
                _buildFeatureRow('📅 Automatic Calendar Exam & Deadline Sync', 'Auto-reads Google/Outlook calendars to scale workouts during exams with 0 guilt.'),
                _buildFeatureRow('🌸 Full Female Health & Period Engine', 'Day 1-3 automatic target drops, PCOS hormonal balancing, and cramp-relief routines.'),
                _buildFeatureRow('🤖 Anti-Robot Adaptive Challenge Engine', 'Struggled on Level 3? Generates an equal consolidation challenge before advancing.'),
                _buildFeatureRow('💬 AI Notification Booster (LLM Coach)', 'Personalized daily motivation in English & Tanglish tailored to your sleep and stress.'),
                _buildFeatureRow('⌚ Smartwatch Ecosystem Live Sync', 'Direct sync with Noise, boAt, Fire-Boltt, Google Fit, and Apple Health.'),

                const SizedBox(height: 16),

                // Smartwatch B2B Partnership Banner (Page 6 & 7)
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('⌚', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          const Text(
                            'Supported Smartwatch Ecosystem',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Powered by our B2B SDK: Noise • boAt • Fire-Boltt • Apple Watch • WearOS',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Welcome to FitSync AI Premium! All AI features unlocked.'),
                        backgroundColor: AppColors.deepTeal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text('Upgrade for ${_selectedTierIndex == 0 ? "₹99/mo (Quarterly)" : "₹149/mo"}'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.mintAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

