import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/injury.dart';
import '../auth/auth_controller.dart';
import '../readiness/readiness_controller.dart';

class InjuryState {
  final InjuryGuard? activeInjury;
  final List<InjuryGuard> pastInjuries;

  const InjuryState({
    this.activeInjury,
    this.pastInjuries = const [],
  });

  bool get hasActiveInjury => activeInjury != null && activeInjury!.isActive;

  InjuryState copyWith({
    InjuryGuard? activeInjury,
    List<InjuryGuard>? pastInjuries,
    bool clearActive = false,
  }) {
    return InjuryState(
      activeInjury: clearActive ? null : (activeInjury ?? this.activeInjury),
      pastInjuries: pastInjuries ?? this.pastInjuries,
    );
  }
}

class InjuryController extends StateNotifier<InjuryState> {
  final Ref _ref;

  InjuryController(this._ref) : super(const InjuryState());

  /// Log an injury in 2 taps
  void logInjury({
    required BodyArea bodyArea,
    required InjurySeverity severity,
    int expectedRecoveryDays = 7,
  }) {
    final auth = _ref.read(authControllerProvider);
    final userId = auth.user?.id ?? 'guest_user';

    final injury = InjuryGuard(
      id: const Uuid().v4(),
      userId: userId,
      bodyArea: bodyArea,
      severity: severity,
      expectedRecoveryDays: expectedRecoveryDays,
      isActive: true,
      loggedAt: DateTime.now(),
    );

    state = state.copyWith(activeInjury: injury);

    // Notify ReadinessController to recalculate with injury penalty
    _ref.read(readinessControllerProvider.notifier).updateCheckin(
      hasActiveInjury: true,
      injurySeverity: severity.name,
    );
  }

  /// Mark the active injury as recovered (1-tap)
  void markRecovered() {
    if (state.activeInjury == null) return;

    final resolved = state.activeInjury!.copyWith(
      isActive: false,
      recoveredAt: DateTime.now(),
    );

    state = state.copyWith(
      clearActive: true,
      pastInjuries: [...state.pastInjuries, resolved],
    );

    // Remove injury penalty from ReadinessController
    _ref.read(readinessControllerProvider.notifier).updateCheckin(
      hasActiveInjury: false,
      injurySeverity: null,
    );
  }
}

final injuryControllerProvider = StateNotifierProvider<InjuryController, InjuryState>((ref) {
  return InjuryController(ref);
});
