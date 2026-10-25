import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/readiness_result.dart';
import 'friendly_mascot.dart';

/// Animated Readiness Ring widget with dynamic score coloring and friendly mascot
class AnimatedReadinessRing extends StatefulWidget {
  final int score;
  final ReadinessBand band;
  final double size;
  final VoidCallback? onTap;

  const AnimatedReadinessRing({
    super.key,
    required this.score,
    required this.band,
    this.size = 200,
    this.onTap,
  });

  @override
  State<AnimatedReadinessRing> createState() => _AnimatedReadinessRingState();
}

class _AnimatedReadinessRingState extends State<AnimatedReadinessRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.score / 100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedReadinessRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: oldWidget.score / 100.0,
        end: widget.score / 100.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = AppColors.getReadinessColor(widget.score);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? const Color(0xFF1F2B37) : const Color(0xFFE9ECEF);

    return GestureDetector(
      onTap: widget.onTap,
      child: Center(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom circular ring painter
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RingPainter(
                      progress: _animation.value,
                      ringColor: ringColor,
                      trackColor: trackColor,
                      strokeWidth: 14.0,
                    ),
                  );
                },
              ),

              // Center content: Mascot, Score, and Band
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FriendlyMascot(band: widget.band, size: 40),
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final displayScore = (_animation.value * 100).round();
                      return Text(
                        '$displayScore',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          color: ringColor,
                        ),
                      );
                    },
                  ),
                  Text(
                    widget.band.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc with Round Cap
    final progressPaint = Paint()
      ..color = ringColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
  }
}
