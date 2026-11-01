import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/mindset_wisdom.dart';
import '../../../core/models/anti_robot_state.dart';
import '../../../core/models/workout.dart';
import '../../../core/widgets/mindset_background.dart';
import '../../../core/widgets/mindset_reset_modal.dart';
import '../../progression/anti_robot_controller.dart';
import '../../scaling/target_controller.dart';
import '../../streaks/streak_controller.dart';

/// Active Workout Player with step-by-step interval timer and completion celebration
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  int _currentStepIndex = 0;
  int _secondsRemaining = 45;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startStep(0);
  }

  void _startStep(int index) {
    _timer?.cancel();
    setState(() {
      _currentStepIndex = index;
      _secondsRemaining = widget.workout.steps[index].durationSeconds;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_secondsRemaining > 1) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          _nextStep();
        }
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  void _nextStep() {
    if (_currentStepIndex < widget.workout.steps.length - 1) {
      _startStep(_currentStepIndex + 1);
    } else {
      _finishWorkout();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      _startStep(_currentStepIndex - 1);
    }
  }

  void _finishWorkout() {
    _timer?.cancel();

    // Advance streak and mark target completed
    ref.read(targetControllerProvider.notifier).markCompleted();
    ref.read(streakControllerProvider.notifier).processTodayCompletion();

    _showCompletionModal();
  }

  void _showCompletionModal() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _WorkoutCompletionSheet(onClose: () {
          Navigator.of(context).pop(); // Dismiss bottom sheet
          Navigator.of(context).pop(); // Return to home/list
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.workout.steps[_currentStepIndex];
    final totalSteps = widget.workout.steps.length;
    final totalDuration = step.durationSeconds;
    final progress = (_secondsRemaining / totalDuration).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MindsetBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.workout.name, style: const TextStyle(fontSize: 16)),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  'Step ${_currentStepIndex + 1} of $totalSteps',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deepTeal),
                ),
              ),
            ),
          ],
        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Linear step progression
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentStepIndex + 1) / totalSteps,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepTeal),
                  minHeight: 6,
                ),
              ),
              const Spacer(),

              // Circular Countdown Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isPaused ? Colors.amber : AppColors.deepTeal).withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: isDark ? const Color(0xFF1F2B37) : const Color(0xFFE9ECEF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isPaused ? Colors.amber : AppColors.deepTeal,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_secondsRemaining',
                        style: TextStyle(
                          fontSize: 68,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          color: _isPaused ? Colors.amber : null,
                        ),
                      ),
                      Text(
                        _isPaused ? 'PAUSED' : 'SECONDS LEFT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: _isPaused ? Colors.amber : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              // Exercise Title & Region
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.2)),
                ),
                child: Text(
                  step.bodyRegion.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AppColors.deepTeal,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                step.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  step.instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const Spacer(),

              // Mindset Breathing & Grounding Pill
              GestureDetector(
                onTap: () {
                  _togglePause();
                  MindsetResetModal.show(context).then((_) {
                    if (mounted && _isPaused) _togglePause();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF2F7F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🧠', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 8),
                      Text(
                        'Mindset: Focus on movement quality • Tap for 1-Min Breath',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.deepTeal),
                      ),
                    ],
                  ),
                ),
              ),

              // Player Controls (Prev, Pause/Play, Next)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 38,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: _currentStepIndex > 0 ? _previousStep : null,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _togglePause,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isPaused
                              ? [Colors.amber, Colors.orange]
                              : [const Color(0xFF0F4C5C), const Color(0xFF2EC4B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isPaused ? Colors.amber : AppColors.deepTeal).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: 38,
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: _nextStep,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _WorkoutCompletionSheet extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const _WorkoutCompletionSheet({required this.onClose});

  @override
  ConsumerState<_WorkoutCompletionSheet> createState() =>
      _WorkoutCompletionSheetState();
}

class _WorkoutCompletionSheetState
    extends ConsumerState<_WorkoutCompletionSheet> {
  ExertionRating? _selectedExertion;

  @override
  Widget build(BuildContext context) {
    final streakState = ref.watch(streakControllerProvider);
    final antiRobot = ref.watch(antiRobotControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mintAccent.withValues(alpha: 0.15),
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Workout Complete!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'You showed up for your body today. Flex Streak is safe and burning bright.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Streak Flame Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warmCoral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${streakState.streak.currentStreak} Day Flex Streak Protected',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warmCoral,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Anti-Robot Exertion Feedback Section (Pages 1 & 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🤖', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Anti-Robot Check: How was this workout?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apps usually push users like robots. We adapt your next challenge to your real stamina.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3 Exertion Options
                  Column(
                    children: ExertionRating.values.map((rating) {
                      final isSelected = _selectedExertion == rating;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedExertion = rating);
                            ref
                                .read(antiRobotControllerProvider.notifier)
                                .recordExertion(rating);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.deepTeal.withValues(alpha: 0.15)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.deepTeal
                                    : (isDark
                                        ? Colors.white12
                                        : Colors.black12),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rating.label,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.deepTeal
                                              : null,
                                        ),
                                      ),
                                      Text(
                                        rating.description,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.deepTeal, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // If Kashtam-ah Irundhuchu selected, display the anti-robot badge
                  if (_selectedExertion == ExertionRating.struggled) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mintAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppColors.mintAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Anti-Robot Guard Triggered: Since Level ${antiRobot.currentLevel} felt tough, we won\'t force Level ${antiRobot.currentLevel + 1} tomorrow. An equivalent consolidation challenge is set instead!',
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepTeal,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

