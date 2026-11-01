import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/health_data.dart';
import '../readiness/readiness_controller.dart';
import 'health_sync_service.dart';

class HealthState {
  final HealthSnapshot snapshot;
  final HealthConnectionStatus status;
  final bool isSyncing;
  final String? errorMessage;
  final bool hasHardwareStepSensor;

  const HealthState({
    required this.snapshot,
    required this.status,
    this.isSyncing = false,
    this.errorMessage,
    this.hasHardwareStepSensor = true,
  });

  HealthState copyWith({
    HealthSnapshot? snapshot,
    HealthConnectionStatus? status,
    bool? isSyncing,
    String? errorMessage,
    bool? hasHardwareStepSensor,
  }) {
    return HealthState(
      snapshot: snapshot ?? this.snapshot,
      status: status ?? this.status,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage ?? this.errorMessage,
      hasHardwareStepSensor: hasHardwareStepSensor ?? this.hasHardwareStepSensor,
    );
  }
}

class HealthController extends StateNotifier<HealthState> {
  final HealthSyncService _service;
  final Ref _ref;

  HealthController(this._service, this._ref)
      : super(HealthState(
          snapshot: HealthSnapshot(
            stepsToday: 4210,
            sleepDurationHours: 7.2,
            sleepQuality: 4,
            restingHeartRateBpm: 65,
            isWearableConnected: true,
            syncedAt: DateTime.now(),
            sourceName: 'Device Step Sensor',
          ),
          status: HealthConnectionStatus.connected,
        ));

  /// Connect to Health Connect / Device Sensors
  Future<void> connectHealth() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    final granted = await _service.requestPermissions();
    if (granted) {
      final snapshot = await _service.fetchTodaySnapshot();
      state = HealthState(
        snapshot: snapshot,
        status: HealthConnectionStatus.connected,
        isSyncing: false,
      );

      // Auto-feed synced sleep into the readiness controller
      _ref.read(readinessControllerProvider.notifier).updateCheckin(
        sleepHours: snapshot.sleepDurationHours,
        sleepQuality: snapshot.sleepQuality,
      );
    } else {
      state = state.copyWith(
        status: HealthConnectionStatus.permissionDenied,
        isSyncing: false,
        errorMessage: 'Health permissions were not granted. Manual fallback active.',
      );
    }
  }

  /// 1-Tap Live Sync steps directly from device pedometer / hardware sensors
  Future<void> syncDeviceSteps() async {
    state = state.copyWith(isSyncing: true);
    await Future<void>.delayed(const Duration(milliseconds: 600)); // Smooth sync UX feel

    final stepData = await _service.fetchDeviceSteps();
    final updatedSnapshot = state.snapshot.copyWith(
      stepsToday: stepData.steps,
      sourceName: stepData.source,
      syncedAt: DateTime.now(),
      isWearableConnected: true,
    );

    state = state.copyWith(
      snapshot: updatedSnapshot,
      status: HealthConnectionStatus.connected,
      isSyncing: false,
      hasHardwareStepSensor: stepData.hasHardwareSensor,
    );
  }

  /// Disconnect and switch back to manual entry
  void disconnect() {
    _service.disconnect();
    state = HealthState(
      snapshot: state.snapshot.copyWith(
        isWearableConnected: false,
        sourceName: 'Manual Entry',
      ),
      status: HealthConnectionStatus.disconnected,
    );
  }

  /// Manual update when user logs their own sleep or steps
  void updateManualMetrics({
    double? sleepHours,
    int? sleepQuality,
    int? steps,
    int? restingHeartRate,
  }) {
    final updated = state.snapshot.copyWith(
      sleepDurationHours: sleepHours,
      sleepQuality: sleepQuality,
      stepsToday: steps,
      restingHeartRateBpm: restingHeartRate,
      sourceName: 'Manual Entry',
    );

    state = state.copyWith(snapshot: updated);

    if (sleepHours != null || sleepQuality != null) {
      _ref.read(readinessControllerProvider.notifier).updateCheckin(
        sleepHours: sleepHours,
        sleepQuality: sleepQuality,
      );
    }
  }
}

final healthServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService();
});

final healthControllerProvider = StateNotifierProvider<HealthController, HealthState>((ref) {
  final service = ref.watch(healthServiceProvider);
  return HealthController(service, ref);
});
