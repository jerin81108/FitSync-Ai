/// Tone options for notification booster
enum NotificationTone {
  friendly('Friendly & Encouraging', '🤝', 'Warm coach vibe focusing on gentle momentum'),
  calm('Calm & Zen', '🧘', 'Mindful, soothing tone focusing on nervous system peace'),
  playful('Playful & Energetic', '⚡', 'Lighthearted, game-like motivation with high vibes');

  final String label;
  final String emoji;
  final String description;

  const NotificationTone(this.label, this.emoji, this.description);

  static NotificationTone fromString(String val) {
    return NotificationTone.values.firstWhere(
      (t) => t.name.toLowerCase() == val.toLowerCase() || t.label.toLowerCase() == val.toLowerCase(),
      orElse: () => NotificationTone.friendly,
    );
  }
}

/// Notification Settings model
class NotificationSettingsModel {
  final bool enabled;
  final String wakeTime; // e.g. "07:30"
  final NotificationTone tone;
  final bool aiBoosterEnabled;
  final int dailyAiCount;
  final DateTime? lastNotificationSentAt;

  const NotificationSettingsModel({
    this.enabled = true,
    this.wakeTime = '07:30',
    this.tone = NotificationTone.friendly,
    this.aiBoosterEnabled = true,
    this.dailyAiCount = 0,
    this.lastNotificationSentAt,
  });

  NotificationSettingsModel copyWith({
    bool? enabled,
    String? wakeTime,
    NotificationTone? tone,
    bool? aiBoosterEnabled,
    int? dailyAiCount,
    DateTime? lastNotificationSentAt,
  }) {
    return NotificationSettingsModel(
      enabled: enabled ?? this.enabled,
      wakeTime: wakeTime ?? this.wakeTime,
      tone: tone ?? this.tone,
      aiBoosterEnabled: aiBoosterEnabled ?? this.aiBoosterEnabled,
      dailyAiCount: dailyAiCount ?? this.dailyAiCount,
      lastNotificationSentAt: lastNotificationSentAt ?? this.lastNotificationSentAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'wake_time': wakeTime,
    'tone': tone.name,
    'ai_booster_enabled': aiBoosterEnabled,
    'daily_ai_count': dailyAiCount,
    'last_notification_sent_at': lastNotificationSentAt?.toIso8601String(),
  };

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      enabled: json['enabled'] as bool? ?? true,
      wakeTime: json['wake_time'] as String? ?? '07:30',
      tone: NotificationTone.fromString(json['tone'] as String? ?? 'friendly'),
      aiBoosterEnabled: json['ai_booster_enabled'] as bool? ?? true,
      dailyAiCount: (json['daily_ai_count'] as num?)?.toInt() ?? 0,
      lastNotificationSentAt: json['last_notification_sent_at'] != null
          ? DateTime.parse(json['last_notification_sent_at'] as String)
          : null,
    );
  }
}
