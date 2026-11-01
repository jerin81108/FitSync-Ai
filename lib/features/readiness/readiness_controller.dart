import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/daily_checkin.dart';
import '../../core/models/readiness_result.dart';
import '../../core/storage/local_storage_service.dart';
import '../auth/auth_controller.dart';
import 'readiness_engine.dart';

class ReadinessState {
  final DailyCheckin checkin;
  final ReadinessResult readiness;
  final bool isCalculating;

  const ReadinessState({
    required this.checkin,
    required this.readiness,
    this.isCalculating = false,
  });

  ReadinessState copyWith({
    DailyCheckin? checkin,
    ReadinessResult? readiness,
    bool? isCalculating,
  }) {
    return ReadinessState(
      checkin: checkin ?? this.checkin,
      readiness: readiness ?? this.readiness,
      isCalculating: isCalculating ?? this.isCalculating,
    );
  }
}

class ReadinessController extends StateNotifier<ReadinessState> {
  final LocalStorageService _storage;
  final ReadinessEngine _engine;

  ReadinessController(this._storage, this._engine, String userId)
      : super(_initialState(_storage, _engine, userId));

  static ReadinessState _initialState(LocalStorageService storage, ReadinessEngine engine, String userId) {
    final cachedCheckin = storage.getLatestCheckin() ?? DailyCheckin.defaultToday(userId: userId);
    final readiness = engine.calculate(checkin: cachedCheckin);
    return ReadinessState(checkin: cachedCheckin, readiness: readiness);
  }

  /// Update any morning check-in parameter and immediately recalculate readiness
  Future<void> updateCheckin({
    MoodEmoji? mood,
    int? stressLevel,
    double? sleepHours,
    int? sleepQuality,
    int? yesterdayWorkoutIntensity,
    bool? isHeavyDay,
    int? scheduleLoadRating,
    bool? isExamDay,
    String? cyclePhase,
    bool? hasActiveInjury,
    String? injurySeverity,
    String? notes,
  }) async {
    state = state.copyWith(isCalculating: true);

    final updatedCheckin = state.checkin.copyWith(
      mood: mood,
      stressLevel: stressLevel,
      sleepHours: sleepHours,
      sleepQuality: sleepQuality,
      yesterdayWorkoutIntensity: yesterdayWorkoutIntensity,
      isHeavyDay: isHeavyDay,
      scheduleLoadRating: scheduleLoadRating,
      isExamDay: isExamDay,
      cyclePhase: cyclePhase,
      hasActiveInjury: hasActiveInjury,
      notes: notes,
    );

    final newReadiness = _engine.calculate(
      checkin: updatedCheckin,
      injurySeverity: injurySeverity,
    );

    await _storage.saveCheckin(updatedCheckin);

    state = ReadinessState(
      checkin: updatedCheckin,
      readiness: newReadiness,
      isCalculating: false,
    );
  }

  /// One-tap toggle for Heavy Day / Free Day override
  Future<void> toggleHeavyDay() async {
    final current = state.checkin.isHeavyDay;
    await updateCheckin(isHeavyDay: !current);
  }

  /// One-tap toggle for Exam Day
  Future<void> toggleExamDay() async {
    final current = state.checkin.isExamDay;
    await updateCheckin(isExamDay: !current);
  }
}

final readinessEngineProvider = Provider<ReadinessEngine>((ref) {
  return const ReadinessEngine();
});

final readinessControllerProvider = StateNotifierProvider<ReadinessController, ReadinessState>((ref) {
  final storage = ref.watch(localStorageProvider);
  final engine = ref.watch(readinessEngineProvider);
  final auth = ref.watch(authControllerProvider);
  final userId = auth.user?.id ?? 'guest_user';

  return ReadinessController(storage, engine, userId);
});
