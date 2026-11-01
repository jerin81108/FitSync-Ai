/// Body regions supported by Injury Guard
enum BodyArea {
  knee('Knee (Mutti Vali 🦵)', '🦵', 'Excludes squats, lunges, and jumping'),
  ankle('Ankle', '🦶', 'Excludes plyometrics and impact running'),
  lowerBack('Lower Back (Mudhugubali 🧘)', '🧘', 'Excludes heavy deadlifts & spinal compression'),
  shoulder('Shoulder', '💪', 'Excludes overhead pressing & pushups'),
  wrist('Wrist', '✋', 'Excludes floor pushups & plank loading'),
  neck('Neck', '👤', 'Excludes neck strain & cervical flexion'),
  hip('Hip', '🏃', 'Excludes deep hinges & lateral leg sprints'),
  foot('Foot', '👟', 'Offloads jumping & sustained impact');

  final String label;
  final String emoji;
  final String affectedExercisesNote;

  const BodyArea(this.label, this.emoji, this.affectedExercisesNote);

  static BodyArea fromString(String val) {
    return BodyArea.values.firstWhere(
      (b) => b.name.toLowerCase() == val.toLowerCase() || b.label.toLowerCase() == val.toLowerCase(),
      orElse: () => BodyArea.knee,
    );
  }
}

/// Injury severity levels
enum InjurySeverity {
  mild(10.0, 'Mild', 'Slight discomfort. Gentle mobility allowed.'),
  moderate(25.0, 'Moderate', 'Noticeable ache. Strictly offload affected zone.'),
  severe(40.0, 'Severe', 'Acute pain. Seated rest & gentle breathing only.');

  final double penaltyPoints;
  final String label;
  final String guidance;

  const InjurySeverity(this.penaltyPoints, this.label, this.guidance);

  static InjurySeverity fromString(String val) {
    return InjurySeverity.values.firstWhere(
      (s) => s.name.toLowerCase() == val.toLowerCase() || s.label.toLowerCase() == val.toLowerCase(),
      orElse: () => InjurySeverity.moderate,
    );
  }
}

/// Injury Guard representation
class InjuryGuard {
  final String id;
  final String userId;
  final BodyArea bodyArea;
  final InjurySeverity severity;
  final int expectedRecoveryDays;
  final bool isActive;
  final DateTime loggedAt;
  final DateTime? recoveredAt;

  const InjuryGuard({
    required this.id,
    required this.userId,
    required this.bodyArea,
    required this.severity,
    this.expectedRecoveryDays = 7,
    this.isActive = true,
    required this.loggedAt,
    this.recoveredAt,
  });

  int get daysRemaining {
    final elapsed = DateTime.now().difference(loggedAt).inDays;
    final remaining = expectedRecoveryDays - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  InjuryGuard copyWith({
    String? id,
    String? userId,
    BodyArea? bodyArea,
    InjurySeverity? severity,
    int? expectedRecoveryDays,
    bool? isActive,
    DateTime? loggedAt,
    DateTime? recoveredAt,
  }) {
    return InjuryGuard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bodyArea: bodyArea ?? this.bodyArea,
      severity: severity ?? this.severity,
      expectedRecoveryDays: expectedRecoveryDays ?? this.expectedRecoveryDays,
      isActive: isActive ?? this.isActive,
      loggedAt: loggedAt ?? this.loggedAt,
      recoveredAt: recoveredAt ?? this.recoveredAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'body_area': bodyArea.name,
    'severity': severity.name,
    'expected_recovery_days': expectedRecoveryDays,
    'is_active': isActive,
    'logged_at': loggedAt.toIso8601String(),
    'recovered_at': recoveredAt?.toIso8601String(),
  };

  factory InjuryGuard.fromJson(Map<String, dynamic> json) {
    return InjuryGuard(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      bodyArea: BodyArea.fromString(json['body_area'] as String? ?? 'knee'),
      severity: InjurySeverity.fromString(json['severity'] as String? ?? 'moderate'),
      expectedRecoveryDays: (json['expected_recovery_days'] as num?)?.toInt() ?? 7,
      isActive: json['is_active'] as bool? ?? true,
      loggedAt: DateTime.parse(json['logged_at'] as String),
      recoveredAt: json['recovered_at'] != null ? DateTime.parse(json['recovered_at'] as String) : null,
    );
  }
}
