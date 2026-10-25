import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/badge.dart';
import '../../core/models/streak_data.dart';
import '../../core/storage/local_storage_service.dart';
import '../auth/auth_controller.dart';
import '../readiness/readiness_controller.dart';
import '../scaling/target_controller.dart';
import 'streak_engine.dart';

class StreakState {
  final StreakData streak;
  final List<AppBadge> badges;
  final String? latestCheerMessage;

  const StreakState({
    required this.streak,
    required this.badges,
    this.latestCheerMessage,
  });

  StreakState copyWith({
    StreakData? streak,
    List<AppBadge>? badges,
    String? latestCheerMessage,
  }) {
    return StreakState(
      streak: streak ?? this.streak,
      badges: badges ?? this.badges,
      latestCheerMessage: latestCheerMessage ?? this.latestCheerMessage,
    );
  }
}

class StreakController extends StateNotifier<StreakState> {
  final LocalStorageService _storage;
  final StreakEngine _engine;
  final Ref _ref;

  StreakController(this._storage, this._engine, this._ref)
      : super(_initialStreak(_storage, _ref));

  static StreakState _initialStreak(LocalStorageService storage, Ref ref) {
    final auth = ref.read(authControllerProvider);
    final userId = auth.user?.id ?? 'guest_user';
    final cached = storage.getStreak() ?? StreakData.initial(userId: userId);

    final unlockedKeys = storage.getUnlockedBadgeKeys().toSet();
    final allBadges = AppBadge.predefinedBadges().map((b) {
      if (unlockedKeys.contains(b.key)) {
        return b.copyWith(isUnlocked: true);
      }
      return b;
    }).toList();

    return StreakState(streak: cached, badges: allBadges);
  }

  /// Process today's activity (workout completed or rest day taken)
  void processTodayCompletion() {
    final target = _ref.read(targetControllerProvider);
    final checkin = _ref.read(readinessControllerProvider).checkin;

    final eval = _engine.processDay(
      currentStreak: state.streak,
      target: target,
      checkin: checkin,
      existingBadges: state.badges,
    );

    // Update badges
    final newlyUnlockedKeys = eval.newlyUnlockedBadges.map((b) => b.key).toSet();
    final updatedBadges = state.badges.map((b) {
      if (newlyUnlockedKeys.contains(b.key)) {
        return b.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return b;
    }).toList();

    state = StreakState(
      streak: eval.updatedStreak,
      badges: updatedBadges,
      latestCheerMessage: eval.coachCheerMessage,
    );

    _storage.saveStreak(eval.updatedStreak);
    _storage.saveUnlockedBadgeKeys(
      updatedBadges.where((b) => b.isUnlocked).map((b) => b.key).toList(),
    );
  }
}

final streakEngineProvider = Provider<StreakEngine>((ref) {
  return const StreakEngine();
});

final streakControllerProvider = StateNotifierProvider<StreakController, StreakState>((ref) {
  final storage = ref.watch(localStorageProvider);
  final engine = ref.watch(streakEngineProvider);
  return StreakController(storage, engine, ref);
});
