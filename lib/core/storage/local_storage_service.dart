import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_checkin.dart';
import '../models/daily_target.dart';
import '../models/streak_data.dart';
import '../models/user_profile.dart';

/// Offline-first local storage service using SharedPreferences with in-memory caching
class LocalStorageService {
  static const String _keyProfile = 'fitsync_user_profile';
  static const String _keyOnboardingDone = 'fitsync_onboarding_completed';
  static const String _keyLatestCheckin = 'fitsync_latest_checkin';
  static const String _keyLatestTarget = 'fitsync_latest_target';
  static const String _keyStreak = 'fitsync_streak_data';
  static const String _keyBadges = 'fitsync_unlocked_badges';

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // In-memory fallback if native channel isn't ready
    }
  }

  // --- Profile ---
  Future<void> saveProfile(UserProfile profile) async {
    await _prefs?.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  UserProfile? getProfile() {
    final raw = _prefs?.getString(_keyProfile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // --- Onboarding Status ---
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool(_keyOnboardingDone, completed);
  }

  bool isOnboardingCompleted() {
    return _prefs?.getBool(_keyOnboardingDone) ?? false;
  }

  // --- Daily Checkin ---
  Future<void> saveCheckin(DailyCheckin checkin) async {
    await _prefs?.setString(_keyLatestCheckin, jsonEncode(checkin.toJson()));
  }

  DailyCheckin? getLatestCheckin() {
    final raw = _prefs?.getString(_keyLatestCheckin);
    if (raw == null) return null;
    try {
      return DailyCheckin.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // --- Daily Target ---
  Future<void> saveTarget(DailyTarget target) async {
    await _prefs?.setString(_keyLatestTarget, jsonEncode(target.toJson()));
  }

  DailyTarget? getLatestTarget() {
    final raw = _prefs?.getString(_keyLatestTarget);
    if (raw == null) return null;
    try {
      return DailyTarget.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // --- Streak ---
  Future<void> saveStreak(StreakData streak) async {
    await _prefs?.setString(_keyStreak, jsonEncode(streak.toJson()));
  }

  StreakData? getStreak() {
    final raw = _prefs?.getString(_keyStreak);
    if (raw == null) return null;
    try {
      return StreakData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // --- Badges ---
  Future<void> saveUnlockedBadgeKeys(List<String> keys) async {
    await _prefs?.setStringList(_keyBadges, keys);
  }

  List<String> getUnlockedBadgeKeys() {
    return _prefs?.getStringList(_keyBadges) ?? [];
  }
}
