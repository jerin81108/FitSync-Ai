import 'package:flutter/material.dart';
import '../models/readiness_result.dart';

/// Friendly mascot representing readiness state and encouragement
class FriendlyMascot extends StatelessWidget {
  final ReadinessBand band;
  final double size;

  const FriendlyMascot({
    super.key,
    required this.band,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBgColor(band),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          band.emoji,
          style: TextStyle(fontSize: size * 0.55),
        ),
      ),
    );
  }

  Color _getBgColor(ReadinessBand band) {
    switch (band) {
      case ReadinessBand.rest:
        return const Color(0xFFE9ECEF);
      case ReadinessBand.light:
        return const Color(0xFFE8F8F5);
      case ReadinessBand.moderate:
        return const Color(0xFFEBF5FB);
      case ReadinessBand.optimal:
        return const Color(0xFFE8F6F3);
      case ReadinessBand.peak:
        return const Color(0xFFFDEDEC);
    }
  }
}
