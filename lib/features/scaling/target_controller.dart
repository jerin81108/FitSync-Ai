import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/daily_target.dart';
import '../../core/storage/local_storage_service.dart';
import '../auth/auth_controller.dart';
import '../readiness/readiness_controller.dart';
import '../workouts/workout_library.dart';
import 'scaling_engine.dart';

class TargetController extends StateNotifier<DailyTarget> {
  final LocalStorageService _storage;
  final ScalingEngine _engine;
  final Ref _ref;

  TargetController(this._storage, this._engine, this._ref)
      : super(_initialTarget(_storage, _engine, _ref)) {
    // Listen to changes in readiness and re-scale target automatically
    _ref.listen(readinessControllerProvider, (previous, next) {
      if (previous?.readiness.score != next.readiness.score ||
          previous?.checkin.isHeavyDay != next.checkin.isHeavyDay ||
          previous?.checkin.isExamDay != next.checkin.isExamDay) {
        _recalculate();
      }
    });
  }

  static DailyTarget _initialTarget(LocalStorageService storage, ScalingEngine engine, Ref ref) {
    final cached = storage.getLatestTarget();
    if (cached != null) return cached;

    final readinessState = ref.read(readinessControllerProvider);
    final auth = ref.read(authControllerProvider);
    final userId = auth.user?.id ?? 'guest_user';

    return engine.scale(
      userId: userId,
      readiness: readinessState.readiness,
      checkin: readinessState.checkin,
      availableWorkouts: WorkoutLibrary.allWorkouts,
    );
  }

  void _recalculate() {
    final readinessState = _ref.read(readinessControllerProvider);
    final auth = _ref.read(authControllerProvider);
    final userId = auth.user?.id ?? 'guest_user';

    final updated = _engine.scale(
      userId: userId,
      readiness: readinessState.readiness,
      checkin: readinessState.checkin,
      availableWorkouts: WorkoutLibrary.allWorkouts,
      manualOverride: state.userManualOverride,
      isIntentionalRestDay: state.isIntentionalRestDay,
    );

    state = updated;
    _storage.saveTarget(updated);
  }

  /// Make target easier (-20%)
  void makeEasier() {
    final current = state.userManualOverride;
    final newOverride = current > -1 ? current - 1 : -1;
    final readinessState = _ref.read(readinessControllerProvider);
    final auth = _ref.read(authControllerProvider);

    final updated = _engine.scale(
      userId: auth.user?.id ?? 'guest_user',
      readiness: readinessState.readiness,
      checkin: readinessState.checkin,
      availableWorkouts: WorkoutLibrary.allWorkouts,
      manualOverride: newOverride,
      isIntentionalRestDay: state.isIntentionalRestDay,
    );

    state = updated;
    _storage.saveTarget(updated);
  }

  /// Make target harder (+20%)
  void makeHarder() {
    final current = state.userManualOverride;
    final newOverride = current < 1 ? current + 1 : 1;
    final readinessState = _ref.read(readinessControllerProvider);
    final auth = _ref.read(authControllerProvider);

    final updated = _engine.scale(
      userId: auth.user?.id ?? 'guest_user',
      readiness: readinessState.readiness,
      checkin: readinessState.checkin,
      availableWorkouts: WorkoutLibrary.allWorkouts,
      manualOverride: newOverride,
      isIntentionalRestDay: state.isIntentionalRestDay,
    );

    state = updated;
    _storage.saveTarget(updated);
  }

  /// Log an intentional rest day (streak is preserved!)
  void logIntentionalRest() {
    final readinessState = _ref.read(readinessControllerProvider);
    final auth = _ref.read(authControllerProvider);

    final updated = _engine.scale(
      userId: auth.user?.id ?? 'guest_user',
      readiness: readinessState.readiness,
      checkin: readinessState.checkin,
      availableWorkouts: WorkoutLibrary.allWorkouts,
      isIntentionalRestDay: true,
    );

    state = updated;
    _storage.saveTarget(updated);
  }

  /// Mark adapted workout as completed
  void markCompleted() {
    final updated = state.copyWith(isCompleted: true);
    state = updated;
    _storage.saveTarget(updated);
  }
}

final scalingEngineProvider = Provider<ScalingEngine>((ref) {
  return const ScalingEngine();
});

final targetControllerProvider = StateNotifierProvider<TargetController, DailyTarget>((ref) {
  final storage = ref.watch(localStorageProvider);
  final engine = ref.watch(scalingEngineProvider);
  return TargetController(storage, engine, ref);
});
