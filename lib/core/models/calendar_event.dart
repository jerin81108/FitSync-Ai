/// Load level assigned to a calendar day
enum EventLoadLevel {
  light(15, 'Light Load', '✨'),
  medium(45, 'Medium Load', '💼'),
  heavy(75, 'Heavy Deadline', '📅'),
  exam(95, 'Exam Day', '🎓');

  final int loadRating;
  final String label;
  final String emoji;

  const EventLoadLevel(this.loadRating, this.label, this.emoji);
}

/// Calendar event item with detected load classification
class CalendarEventItem {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final EventLoadLevel loadLevel;
  final bool isExam;
  final bool isUserOverride;

  const CalendarEventItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.loadLevel,
    this.isExam = false,
    this.isUserOverride = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'load_level': loadLevel.name,
    'is_exam': isExam,
    'is_user_override': isUserOverride,
  };

  factory CalendarEventItem.fromJson(Map<String, dynamic> json) {
    final isExam = json['is_exam'] as bool? ?? false;
    final loadName = json['load_level'] as String? ?? 'light';
    final load = EventLoadLevel.values.firstWhere(
      (l) => l.name == loadName,
      orElse: () => isExam ? EventLoadLevel.exam : EventLoadLevel.light,
    );

    return CalendarEventItem(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      loadLevel: load,
      isExam: isExam,
      isUserOverride: json['is_user_override'] as bool? ?? false,
    );
  }
}
