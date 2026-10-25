/// Connection state of Health data provider (Health Connect / HealthKit)
enum HealthConnectionStatus {
  disconnected,
  connecting,
  connected,
  permissionDenied,
  manualOnly,
}

/// Snapshot of health metrics synced from wearable or health store
class HealthSnapshot {
  final int stepsToday;
  final double sleepDurationHours;
  final int sleepQuality; // 1 (Restless) to 5 (Deep)
  final int? restingHeartRateBpm;
  final bool isWearableConnected;
  final DateTime syncedAt;
  final String sourceName; // e.g. "Health Connect", "HealthKit", "Manual Fallback"

  const HealthSnapshot({
    required this.stepsToday,
    required this.sleepDurationHours,
    required this.sleepQuality,
    this.restingHeartRateBpm,
    required this.isWearableConnected,
    required this.syncedAt,
    this.sourceName = 'Health Connect',
  });

  factory HealthSnapshot.initial() {
    return HealthSnapshot(
      stepsToday: 4250,
      sleepDurationHours: 7.5,
      sleepQuality: 4,
      restingHeartRateBpm: 64,
      isWearableConnected: false,
      syncedAt: DateTime.now(),
      sourceName: 'Manual Fallback',
    );
  }

  HealthSnapshot copyWith({
    int? stepsToday,
    double? sleepDurationHours,
    int? sleepQuality,
    int? restingHeartRateBpm,
    bool? isWearableConnected,
    DateTime? syncedAt,
    String? sourceName,
  }) {
    return HealthSnapshot(
      stepsToday: stepsToday ?? this.stepsToday,
      sleepDurationHours: sleepDurationHours ?? this.sleepDurationHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      restingHeartRateBpm: restingHeartRateBpm ?? this.restingHeartRateBpm,
      isWearableConnected: isWearableConnected ?? this.isWearableConnected,
      syncedAt: syncedAt ?? this.syncedAt,
      sourceName: sourceName ?? this.sourceName,
    );
  }

  Map<String, dynamic> toJson() => {
    'steps_today': stepsToday,
    'sleep_duration_hours': sleepDurationHours,
    'sleep_quality': sleepQuality,
    'resting_heart_rate_bpm': restingHeartRateBpm,
    'is_wearable_connected': isWearableConnected,
    'synced_at': syncedAt.toIso8601String(),
    'source_name': sourceName,
  };

  factory HealthSnapshot.fromJson(Map<String, dynamic> json) {
    return HealthSnapshot(
      stepsToday: (json['steps_today'] as num?)?.toInt() ?? 0,
      sleepDurationHours: (json['sleep_duration_hours'] as num?)?.toDouble() ?? 7.0,
      sleepQuality: (json['sleep_quality'] as num?)?.toInt() ?? 3,
      restingHeartRateBpm: (json['resting_heart_rate_bpm'] as num?)?.toInt(),
      isWearableConnected: json['is_wearable_connected'] as bool? ?? false,
      syncedAt: json['synced_at'] != null ? DateTime.parse(json['synced_at'] as String) : DateTime.now(),
      sourceName: json['source_name'] as String? ?? 'Manual Fallback',
    );
  }
}
