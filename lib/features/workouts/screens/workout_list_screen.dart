import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/mindset_wisdom.dart';
import '../../../core/models/workout.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mindset_background.dart';
import '../../../core/widgets/mindset_reset_modal.dart';
import '../../injury/injury_controller.dart';
import '../../injury/widgets/active_injury_banner.dart';
import '../../progression/anti_robot_controller.dart';
import '../workout_library.dart';
import 'active_workout_screen.dart';

/// Workout Library screen displaying routines with Mindset Intention selector, category filter chips, and injury guard filtering
class WorkoutListScreen extends ConsumerStatefulWidget {
  final void Function(Workout workout)? onSelectWorkout;

  const WorkoutListScreen({super.key, this.onSelectWorkout});

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  String _selectedTag = 'all';
  int _selectedIntentionIndex = 0;

  final List<(String, String)> _tags = [
    ('all', 'All Routines'),
    ('quick-15', 'Quick 15'),
    ('low-impact', 'Low Impact'),
    ('no-equipment', 'Zero Equipment'),
    ('stress-relief', 'Stress Relief'),
    ('cramp-relief', 'Cramp Relief'),
    ('yoga', 'Yoga & Stretch'),
    ('upper-body', 'Upper Body'),
    ('lower-body', 'Lower Body'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final injuryState = ref.watch(injuryControllerProvider);

    // Apply injury guard filter if an injury is active
    List<Workout> baseWorkouts = WorkoutLibrary.allWorkouts;
    if (injuryState.hasActiveInjury) {
      baseWorkouts = WorkoutLibrary.filterForInjury(
        workouts: baseWorkouts,
        injuredBodyArea: injuryState.activeInjury!.bodyArea.name,
      );
    }

    final workouts = _selectedTag == 'all'
        ? baseWorkouts
        : baseWorkouts.where((w) => w.hasTag(_selectedTag)).toList();

    final antiRobot = ref.watch(antiRobotControllerProvider);
    final currentIntention = MindsetWisdom.workoutIntentions[_selectedIntentionIndex];

    return MindsetBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Workout Library'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Anti-Robot Level Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: antiRobot.isConsolidating
                      ? AppColors.mintAccent.withValues(alpha: 0.12)
                      : AppColors.deepTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: antiRobot.isConsolidating
                        ? AppColors.mintAccent.withValues(alpha: 0.3)
                        : AppColors.deepTeal.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Text(antiRobot.isConsolidating ? '🛡️' : '🤖', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            antiRobot.levelTitle,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            antiRobot.isConsolidating
                                ? 'Consolidating Stamina: Equivalent challenge assigned'
                                : 'Adaptive Progression: Calibrates to your real fatigue',
                            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Workout Mindset Intention Banner (Mindset Enhancement)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mintAccent.withValues(alpha: 0.15),
                      AppColors.deepTeal.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mintAccent.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🧠', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            const Text(
                              'Today\'s Movement Intention',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.deepTeal),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => MindsetResetModal.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.deepTeal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Text('🧘 1-Min Reset', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.deepTeal)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(MindsetWisdom.workoutIntentions.length, (i) {
                          final it = MindsetWisdom.workoutIntentions[i];
                          final isSelected = _selectedIntentionIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('${it.emoji} ${it.intention}'),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) setState(() => _selectedIntentionIndex = i);
                              },
                              selectedColor: AppColors.deepTeal.withValues(alpha: 0.18),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.deepTeal : null,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${currentIntention.description}"',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active Injury Banner
            if (injuryState.hasActiveInjury)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: ActiveInjuryBanner(),
              ),

            // Tag Filter Chips Bar
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tags.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final t = _tags[index];
                  final isSelected = _selectedTag == t.$1;
                  return ChoiceChip(
                    label: Text(t.$2),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedTag = t.$1);
                    },
                    selectedColor: AppColors.deepTeal.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.deepTeal : AppColors.lightTextSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Workout Cards List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: workouts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final w = workouts[index];
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
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: (w.tags.contains('cramp-relief')
                                            ? AppColors.warmCoral
                                            : AppColors.deepTeal)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      w.tags.contains('cramp-relief')
                                          ? '🌸'
                                          : (w.tags.contains('yoga')
                                              ? '🧘'
                                              : (w.tags.contains('quick-15')
                                                  ? '⚡'
                                                  : '🏃')),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.deepTeal.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${w.durationMinutes} min',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.deepTeal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: List.generate(5, (dotIndex) {
                                return Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                    color: dotIndex < w.intensity
                                        ? AppColors.warmCoral
                                        : (isDark ? Colors.white12 : Colors.black12),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          w.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          w.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF4F6F8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    w.equipment,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.mintAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '🧠 Mindful',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.deepTeal),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (widget.onSelectWorkout != null) {
                                  widget.onSelectWorkout!(w);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) => ActiveWorkoutScreen(workout: w),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepTeal,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Start Routine',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
