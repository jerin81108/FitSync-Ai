import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/mindset_wisdom.dart';

/// Interactive 1-Minute Mindset Reset & Box Breathing Modal
/// Calms nervous system, relieves workout guilt, and resets focus before or after movement.
class MindsetResetModal extends StatefulWidget {
  const MindsetResetModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MindsetResetModal(),
    );
  }

  @override
  State<MindsetResetModal> createState() => _MindsetResetModalState();
}

class _MindsetResetModalState extends State<MindsetResetModal> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  Timer? _phaseTimer;

  int _cycleCount = 0;
  String _currentPhase = 'Inhale'; // 'Inhale', 'Hold', 'Exhale', 'Rest'
  String _phaseAffirmation = 'Breathe in clarity and presence...';
  int _secondsRemaining = 4;
  bool _isPlaying = true;

  final List<String> _mindsetMantras = [
    'I move to nourish my body, not to punish it.',
    'Rest is not failure; rest is fuel.',
    'Showing up today is already 100% of the victory.',
    'Consistency always beats occasional heroics.',
    'My worth is not defined by burning calories.',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );

    _startBreathingLoop();
  }

  void _startBreathingLoop() {
    _animController.forward();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isPlaying) return;

      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _secondsRemaining = 4;
          _nextPhase();
        }
      });
    });
  }

  void _nextPhase() {
    if (_currentPhase == 'Inhale') {
      _currentPhase = 'Hold';
      _phaseAffirmation = 'Anchor into this exact moment...';
    } else if (_currentPhase == 'Hold') {
      _currentPhase = 'Exhale';
      _phaseAffirmation = 'Release anxiety, comparison, and guilt...';
      _animController.reverse();
    } else if (_currentPhase == 'Exhale') {
      _currentPhase = 'Rest';
      _phaseAffirmation = 'Stillness is where growth takes root...';
    } else {
      _currentPhase = 'Inhale';
      _cycleCount++;
      _phaseAffirmation = _mindsetMantras[_cycleCount % _mindsetMantras.length];
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131E24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: AppColors.deepTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🧠', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1-Minute Mindset Reset',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Box breathing & positive cognitive reframing',
                        style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Pulsing Breathing Circle
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.mintAccent.withValues(alpha: 0.35),
                        AppColors.deepTeal.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepTeal.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.deepTeal.withValues(alpha: 0.6),
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPhase.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: AppColors.deepTeal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_secondsRemaining s',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Mindset Affirmation Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF4F9F8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.deepTeal.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _phaseAffirmation,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bottom Controls & Cycle count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Breath Cycle: ${_cycleCount + 1}/4',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.lightTextSecondary),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🌿 Mindset centered. You are ready for today!'),
                      backgroundColor: AppColors.deepTeal,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                label: const Text('I Feel Centered', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

