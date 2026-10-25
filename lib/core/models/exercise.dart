/// Individual exercise step within a workout
class ExerciseStep {
  final String id;
  final String name;
  final int durationSeconds;
  final int repCount; // 0 if time-based
  final String instruction;
  final String bodyRegion; // 'upper_body', 'lower_body', 'core', 'full_body', 'seated_mobility'
  final String illustrationKey;

  const ExerciseStep({
    required this.id,
    required this.name,
    this.durationSeconds = 45,
    this.repCount = 0,
    required this.instruction,
    required this.bodyRegion,
    this.illustrationKey = 'exercise_default',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'duration_seconds': durationSeconds,
    'rep_count': repCount,
    'instruction': instruction,
    'body_region': bodyRegion,
    'illustration_key': illustrationKey,
  };

  factory ExerciseStep.fromJson(Map<String, dynamic> json) {
    return ExerciseStep(
      id: json['id'] as String,
      name: json['name'] as String,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 45,
      repCount: (json['rep_count'] as num?)?.toInt() ?? 0,
      instruction: json['instruction'] as String,
      bodyRegion: json['body_region'] as String,
      illustrationKey: json['illustration_key'] as String? ?? 'exercise_default',
    );
  }
}
