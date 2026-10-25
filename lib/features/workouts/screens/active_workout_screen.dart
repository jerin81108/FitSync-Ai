import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/workout.dart';
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
    final streakState = ref.read(streakControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mintAccent.withValues(alpha: 0.15),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 42)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Workout Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'You showed up for your body today. Flex Streak is safe and burning bright.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Streak celebration banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.warmCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      '${streakState.streak.currentStreak} Day Flex Streak',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warmCoral,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss bottom sheet
                  Navigator.of(context).pop(); // Return to home/list
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
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
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
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
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                        ),
                      ),
                      Text(
                        _isPaused ? 'PAUSED' : 'SECONDS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  step.bodyRegion.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepTeal,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                step.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                step.instruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),

              // Player Controls (Prev, Pause/Play, Next)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: _currentStepIndex > 0 ? _previousStep : null,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _togglePause,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.deepTeal,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    iconSize: 36,
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
    );
  }
}
