import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/workout.dart';
import '../../../core/widgets/glass_card.dart';
import '../../injury/injury_controller.dart';
import '../../injury/widgets/active_injury_banner.dart';
import '../workout_library.dart';
import 'active_workout_screen.dart';

/// Workout Library screen displaying routines with category filter chips and injury guard filtering
class WorkoutListScreen extends ConsumerStatefulWidget {
  final void Function(Workout workout)? onSelectWorkout;

  const WorkoutListScreen({super.key, this.onSelectWorkout});

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  String _selectedTag = 'all';

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Workout Library'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Injury Banner
            if (injuryState.hasActiveInjury)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: ActiveInjuryBanner(),
              ),

            // Tag Filter Chips Bar
            SizedBox(
              height: 48,
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
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Workout Cards List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: workouts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final w = workouts[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            // Intensity dots
                            Row(
                              children: [
                                const Text(
                                  'Intensity ',
                                  style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                                ),
                                ...List.generate(5, (dotIndex) {
                                  final isFilled = dotIndex < w.intensity;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFilled ? AppColors.warmCoral : Colors.grey.withValues(alpha: 0.3),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          w.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          w.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tags & Start Button Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${w.steps.length} intervals • ${w.equipment}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightTextSecondary,
                              ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                minimumSize: const Size(0, 38),
                              ),
                              child: const Text('Start', style: TextStyle(fontSize: 13)),
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
    );
  }
}
