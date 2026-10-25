import 'exercise.dart';

/// Workout Routine model
class Workout {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final int intensity; // 1 (Gentle) to 5 (High Intensity)
  final String equipment; // 'None', 'Dumbbells', 'Mat', 'Chair'
  final String bodyRegion; // 'full_body', 'upper_body', 'lower_body', 'core', 'seated_mobility'
  final List<String> tags; // 'low-impact', 'no-equipment', 'upper-body', 'lower-body', 'yoga', 'cramp-relief', 'stress-relief', 'quick-15'
  final List<ExerciseStep> steps;
  final String illustrationKey;
  final bool isPremium;

  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.intensity,
    required this.equipment,
    required this.bodyRegion,
    required this.tags,
    required this.steps,
    this.illustrationKey = 'workout_default',
    this.isPremium = false,
  });

  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  bool loadsBodyRegion(String region) {
    if (bodyRegion == 'full_body') return true;
    return bodyRegion.toLowerCase() == region.toLowerCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'duration_minutes': durationMinutes,
    'intensity': intensity,
    'equipment': equipment,
    'body_region': bodyRegion,
    'tags': tags,
    'instruction_steps': steps.map((s) => s.toJson()).toList(),
    'illustration_key': illustrationKey,
    'is_premium': isPremium,
  };

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      intensity: (json['intensity'] as num).toInt(),
      equipment: json['equipment'] as String,
      bodyRegion: json['body_region'] as String,
      tags: List<String>.from(json['tags'] as List? ?? []),
      steps: (json['instruction_steps'] as List? ?? [])
          .map((s) => ExerciseStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      illustrationKey: json['illustration_key'] as String? ?? 'workout_default',
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }
}
