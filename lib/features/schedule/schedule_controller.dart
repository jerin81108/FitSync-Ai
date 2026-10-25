import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/calendar_event.dart';
import '../readiness/readiness_controller.dart';
import 'schedule_sync_service.dart';

class ScheduleState {
  final bool isConnected;
  final List<CalendarEventItem> events;
  final DateTime selectedDate;
  final Map<String, EventLoadLevel> manualOverrides; // 'YYYY-MM-DD' -> load

  const ScheduleState({
    required this.isConnected,
    required this.events,
    required this.selectedDate,
    this.manualOverrides = const {},
  });

  EventLoadLevel getEffectiveLoadForDate(DateTime date) {
    final key = _formatDate(date);
    if (manualOverrides.containsKey(key)) {
      return manualOverrides[key]!;
    }

    final dayEvents = events.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();

    if (dayEvents.any((e) => e.isExam || e.loadLevel == EventLoadLevel.exam)) {
      return EventLoadLevel.exam;
    }
    if (dayEvents.any((e) => e.loadLevel == EventLoadLevel.heavy)) {
      return EventLoadLevel.heavy;
    }
    if (dayEvents.any((e) => e.loadLevel == EventLoadLevel.medium)) {
      return EventLoadLevel.medium;
    }
    return EventLoadLevel.light;
  }

  static String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  ScheduleState copyWith({
    bool? isConnected,
    List<CalendarEventItem>? events,
    DateTime? selectedDate,
    Map<String, EventLoadLevel>? manualOverrides,
  }) {
    return ScheduleState(
      isConnected: isConnected ?? this.isConnected,
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      manualOverrides: manualOverrides ?? this.manualOverrides,
    );
  }
}

class ScheduleController extends StateNotifier<ScheduleState> {
  final Ref _ref;

  ScheduleController(this._ref)
      : super(ScheduleState(
          isConnected: true,
          events: ScheduleSyncService.getSampleWeekEvents(),
          selectedDate: DateTime.now(),
        ));

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void toggleGoogleCalendar() {
    state = state.copyWith(isConnected: !state.isConnected);
  }

  /// 1-Tap manual override for any day ("Mark as heavy day / free day / exam day")
  void setDayOverride(DateTime date, EventLoadLevel level) {
    final key = ScheduleState._formatDate(date);
    final updated = Map<String, EventLoadLevel>.from(state.manualOverrides);
    updated[key] = level;

    state = state.copyWith(manualOverrides: updated);

    // If today is modified, sync into readiness controller
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      final isExam = level == EventLoadLevel.exam;
      final isHeavy = level == EventLoadLevel.heavy || isExam;
      _ref.read(readinessControllerProvider.notifier).updateCheckin(
        isExamDay: isExam,
        isHeavyDay: isHeavy,
        scheduleLoadRating: level.loadRating,
      );
    }
  }

  /// Clear manual override for date
  void clearDayOverride(DateTime date) {
    final key = ScheduleState._formatDate(date);
    final updated = Map<String, EventLoadLevel>.from(state.manualOverrides);
    updated.remove(key);

    state = state.copyWith(manualOverrides: updated);

    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      final effective = state.getEffectiveLoadForDate(now);
      _ref.read(readinessControllerProvider.notifier).updateCheckin(
        isExamDay: effective == EventLoadLevel.exam,
        isHeavyDay: effective == EventLoadLevel.heavy || effective == EventLoadLevel.exam,
        scheduleLoadRating: effective.loadRating,
      );
    }
  }
}

final scheduleControllerProvider = StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  return ScheduleController(ref);
});
