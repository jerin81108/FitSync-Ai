import '../../core/models/calendar_event.dart';

/// Service parsing events and auto-detecting life load keywords
class ScheduleSyncService {
  static const List<String> examKeywords = [
    'exam',
    'test',
    'viva',
    'midterm',
    'finals',
    'quiz',
    'board exam',
    'semester exam',
  ];

  static const List<String> heavyKeywords = [
    'submission',
    'deadline',
    'interview',
    'presentation',
    'project due',
    'thesis defense',
    'hackathon',
  ];

  static const List<String> mediumKeywords = [
    'lab',
    'lecture',
    'class',
    'workshop',
    'seminar',
    'shift',
    'group study',
  ];

  /// Auto-detect load level from event title
  static ({EventLoadLevel level, bool isExam}) detectLoad(String title) {
    final lower = title.toLowerCase();

    for (final kw in examKeywords) {
      if (lower.contains(kw)) {
        return (level: EventLoadLevel.exam, isExam: true);
      }
    }

    for (final kw in heavyKeywords) {
      if (lower.contains(kw)) {
        return (level: EventLoadLevel.heavy, isExam: false);
      }
    }

    for (final kw in mediumKeywords) {
      if (lower.contains(kw)) {
        return (level: EventLoadLevel.medium, isExam: false);
      }
    }

    return (level: EventLoadLevel.light, isExam: false);
  }

  /// Generate sample academic week for college student testing
  static List<CalendarEventItem> getSampleWeekEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      CalendarEventItem(
        id: 'ev_1',
        title: 'Algorithms Midterm Exam',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 13)),
        loadLevel: EventLoadLevel.exam,
        isExam: true,
      ),
      CalendarEventItem(
        id: 'ev_2',
        title: 'DBMS Project Submission & Viva',
        startTime: today.add(const Duration(days: 1, hours: 14)),
        endTime: today.add(const Duration(days: 1, hours: 17)),
        loadLevel: EventLoadLevel.heavy,
        isExam: false,
      ),
      CalendarEventItem(
        id: 'ev_3',
        title: 'Cloud Computing Lab & Workshop',
        startTime: today.add(const Duration(days: 2, hours: 9)),
        endTime: today.add(const Duration(days: 2, hours: 12)),
        loadLevel: EventLoadLevel.medium,
        isExam: false,
      ),
      CalendarEventItem(
        id: 'ev_4',
        title: 'Open Weekend & Free Evening',
        startTime: today.add(const Duration(days: 4, hours: 16)),
        endTime: today.add(const Duration(days: 4, hours: 19)),
        loadLevel: EventLoadLevel.light,
        isExam: false,
      ),
    ];
  }
}
