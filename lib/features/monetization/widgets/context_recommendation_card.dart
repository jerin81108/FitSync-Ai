import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/daily_checkin.dart';
import '../../../core/widgets/glass_card.dart';
import '../../readiness/readiness_controller.dart';

/// Context-Aware Wellness Recommendation Card (Pages 7 & 8 of FitSync AI Spec)
/// Dynamically recommends healthy supplements & recovery aids based on user's real-life load:
/// - Exam Day / High Stress: Organic Badam & Stress-Relief Green Tea
/// - Menstrual Phase / Cramps: Herbal Heating Patch & Soothing Spearmint Tea
/// - Low Sleep: Magnesium Glycinate & Sleep Chamomile Elixir
/// - Push / High Energy: Plant Protein & Himalayan Electrolytes
class ContextRecommendationCard extends ConsumerWidget {
  const ContextRecommendationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readinessState = ref.watch(readinessControllerProvider);
    final checkin = readinessState.checkin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recommendation = _getRecommendation(checkin);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(recommendation.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    recommendation.categoryTag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepTeal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mintAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '🌿 0% Spam • 100% Contextual',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mintAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            recommendation.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.description,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        recommendation.price,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        recommendation.originalPrice,
                        style: TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Use code FITSYNC15 for 15% off',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmCoral,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showAffiliateSheet(context, recommendation, isDark);
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 14),
                label: const Text('View Deal', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAffiliateSheet(BuildContext context, _Recommendation rec, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(rec.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        Text('Curated by FitSync AI Partner Brands', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                rec.extendedInfo,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mintAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Coupon: FITSYNC15 applied', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepTeal)),
                    Text(rec.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Redirecting to partner checkout with 15% discount applied!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Order with 1-Tap Partner Checkout'),
              ),
            ],
          ),
        );
      },
    );
  }

  _Recommendation _getRecommendation(DailyCheckin checkin) {
    if (checkin.cyclePhase?.toLowerCase() == 'menstrual') {
      return const _Recommendation(
        emoji: '🌸',
        categoryTag: 'CRAMP & CYCLE RELIEF',
        title: 'Herbal Heating Patch & Spearmint Infusion',
        description: 'Targeted soothing warmth for abdominal and lower back cramps. 100% natural herbs with zero chemicals.',
        extendedInfo: 'Specially engineered for menstrual relief. Provides 8 hours of gentle deep-penetrating warmth paired with pure organic spearmint tea to soothe pelvic muscles and restore calm.',
        price: '₹249',
        originalPrice: '₹399',
      );
    }

    if (checkin.isExamDay || checkin.stressLevel >= 4) {
      return const _Recommendation(
        emoji: '🧠',
        categoryTag: 'EXAM BRAIN RESET & STRESS RELIEF',
        title: 'Stress-Relief Green Tea & Organic California Badam',
        description: 'Rich in L-Theanine and magnesium to lower exam cortisol and clear brain fog without sleepiness.',
        extendedInfo: 'Packed with pure Himalayan green tea leaf extracts and premium California organic almonds (badam). Scientifically proven to support cognitive endurance, memory retention, and mental calm during heavy study weeks.',
        price: '₹299',
        originalPrice: '₹449',
      );
    }

    if (checkin.sleepHours < 5.5) {
      return const _Recommendation(
        emoji: '😴',
        categoryTag: 'CELLULAR SLEEP RECOVERY',
        title: 'Magnesium Glycinate & Sleep Chamomile Elixir',
        description: 'Recharges fatigued nervous systems after short sleep nights without caffeine spikes.',
        extendedInfo: 'Chelated magnesium glycinate gently relaxes tense muscles and supports neural repair when you have slept under 5.5 hours, keeping you revitalized for the day.',
        price: '₹349',
        originalPrice: '₹499',
      );
    }

    return const _Recommendation(
      emoji: '⚡',
      categoryTag: 'CLEAN ATHLETE RECOVERY',
      title: 'Plant Protein & Himalayan Natural Electrolytes',
      description: 'Zero artificial sugars. Keeps muscle recovery rapid and hydration balanced throughout the day.',
      extendedInfo: 'Clean organic plant protein isolate combined with unrefined pink Himalayan mineral salts to fuel optimal metabolic energy.',
      price: '₹399',
      originalPrice: '₹599',
    );
  }
}

class _Recommendation {
  final String emoji;
  final String categoryTag;
  final String title;
  final String description;
  final String extendedInfo;
  final String price;
  final String originalPrice;

  const _Recommendation({
    required this.emoji,
    required this.categoryTag,
    required this.title,
    required this.description,
    required this.extendedInfo,
    required this.price,
    required this.originalPrice,
  });
}

