import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/notification_settings.dart';
import '../readiness/readiness_controller.dart';
import 'notification_templates.dart';

class NotificationController extends StateNotifier<NotificationSettingsModel> {
  final Ref _ref;

  NotificationController(this._ref) : super(const NotificationSettingsModel());

  void setWakeTime(String time) {
    state = state.copyWith(wakeTime: time);
  }

  void setTone(NotificationTone tone) {
    state = state.copyWith(tone: tone);
  }

  void toggleEnabled(bool enabled) {
    state = state.copyWith(enabled: enabled);
  }

  /// Preview current notification based on today's live readiness context
  String getTodayNotificationMessage() {
    final readinessState = _ref.read(readinessControllerProvider);
    final checkin = readinessState.checkin;
    final readiness = readinessState.readiness;

    String contextKey = 'regular_morning';
    if (checkin.isExamDay) {
      contextKey = 'exam_day';
    } else if (checkin.sleepHours < 5.5) {
      contextKey = 'low_sleep';
    } else if (checkin.stressLevel >= 4) {
      contextKey = 'high_stress';
    } else if (readiness.score >= 93) {
      contextKey = 'push_day';
    } else if (checkin.isHeavyDay) {
      contextKey = 'rest_day';
    }

    return NotificationTemplates.getMessage(
      context: contextKey,
      tone: state.tone,
    );
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, NotificationSettingsModel>((ref) {
  return NotificationController(ref);
});
