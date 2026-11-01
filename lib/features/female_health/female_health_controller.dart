import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/female_health_state.dart';
import '../readiness/readiness_controller.dart';

final femaleHealthControllerProvider =
    StateNotifierProvider<FemaleHealthController, FemaleHealthState>((ref) {
  return FemaleHealthController(ref);
});

class FemaleHealthController extends StateNotifier<FemaleHealthState> {
  final Ref _ref;

  FemaleHealthController(this._ref) : super(const FemaleHealthState()) {
    _loadFromStorage();
  }

  static const _storageKey = 'fitsync_female_health_state';

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = FemaleHealthState.fromJson(decoded);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  Future<void> toggleCycleTracking(bool enabled) async {
    state = state.copyWith(isCycleTrackingEnabled: enabled);
    await _saveToStorage();
    _syncWithReadiness();
  }

  Future<void> setPhase(CyclePhase phase, {int periodDay = 1}) async {
    final isPeriod = phase == CyclePhase.menstrual;
    state = state.copyWith(
      currentPhase: phase,
      periodDay: periodDay,
      isCrampReliefActive: isPeriod,
    );
    await _saveToStorage();
    _syncWithReadiness();
  }

  Future<void> togglePcosMode(bool enabled) async {
    state = state.copyWith(isPcosPcodMode: enabled);
    await _saveToStorage();
    _syncWithReadiness();
  }

  Future<void> setEnvironment(WorkoutEnvironment env) async {
    state = state.copyWith(workoutEnvironment: env);
    await _saveToStorage();
    _syncWithReadiness();
  }

  void _syncWithReadiness() {
    final readinessNotifier = _ref.read(readinessControllerProvider.notifier);
    final phaseStr = state.isCycleTrackingEnabled
        ? (state.currentPhase == CyclePhase.menstrual ? 'menstrual' : state.currentPhase.name)
        : null;

    readinessNotifier.updateCheckin(
      cyclePhase: phaseStr,
    );
  }
}

