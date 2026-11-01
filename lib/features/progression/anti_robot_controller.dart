import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/anti_robot_state.dart';

final antiRobotControllerProvider =
    StateNotifierProvider<AntiRobotController, AntiRobotState>((ref) {
  return AntiRobotController();
});

class AntiRobotController extends StateNotifier<AntiRobotState> {
  AntiRobotController() : super(const AntiRobotState()) {
    _loadFromStorage();
  }

  static const _storageKey = 'fitsync_anti_robot_state';

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        state = AntiRobotState.fromJson(decoded);
      }
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  /// Process post-workout exertion rating from user
  Future<void> recordExertion(ExertionRating rating) async {
    if (rating == ExertionRating.struggled) {
      // User struggled: Do not jump to next level like a robot!
      // Assign equivalent consolidation challenge at same level.
      state = state.copyWith(
        isConsolidating: true,
        lastExertionFeedback: 'struggled',
        completedWorkoutsAtLevel: state.completedWorkoutsAtLevel + 1,
        coachNote:
            'Kashtam-ah irundhucha? No problem! FitSync AI won’t treat you like a robot and force Level ${state.currentLevel + 1}. Tomorrow you will do an equivalent consolidation challenge to build stamina naturally.',
      );
    } else if (rating == ExertionRating.easy) {
      // User found it easy: Advance to next level if ready
      final nextLevel = (state.currentLevel + 1).clamp(1, 5);
      state = state.copyWith(
        currentLevel: nextLevel,
        levelTitle: AntiRobotState.getTitleForLevel(nextLevel),
        isConsolidating: false,
        lastExertionFeedback: 'easy',
        completedWorkoutsAtLevel: 1,
        coachNote:
            'You cruised through Level ${state.currentLevel}! Level $nextLevel unlocked with safe incremental intensity.',
      );
    } else {
      // Just right: Solid steady progression
      if (state.completedWorkoutsAtLevel >= 3 && state.isConsolidating) {
        final nextLevel = (state.currentLevel + 1).clamp(1, 5);
        state = state.copyWith(
          currentLevel: nextLevel,
          levelTitle: AntiRobotState.getTitleForLevel(nextLevel),
          isConsolidating: false,
          lastExertionFeedback: 'just_right',
          completedWorkoutsAtLevel: 1,
          coachNote:
              'Base secured! You consolidated Level ${state.currentLevel} and are now fully ready for Level $nextLevel.',
        );
      } else {
        state = state.copyWith(
          lastExertionFeedback: 'just_right',
          completedWorkoutsAtLevel: state.completedWorkoutsAtLevel + 1,
          coachNote:
              'Great steady pace. Building muscular endurance without burnout.',
        );
      }
    }

    await _saveToStorage();
  }

  /// Reset or adjust level manually
  Future<void> setLevel(int level) async {
    final clamped = level.clamp(1, 5);
    state = state.copyWith(
      currentLevel: clamped,
      levelTitle: AntiRobotState.getTitleForLevel(clamped),
      isConsolidating: false,
      completedWorkoutsAtLevel: 1,
      coachNote: 'Adjusted to ${AntiRobotState.getTitleForLevel(clamped)}.',
    );
    await _saveToStorage();
  }
}

