import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_profile.dart';
import '../auth/auth_controller.dart';

class OnboardingState {
  final int currentStep;
  final int totalSteps;
  final UserProfile profileDraft;
  final bool healthPermissionGranted;
  final bool calendarPermissionGranted;
  final bool notificationPermissionGranted;

  const OnboardingState({
    this.currentStep = 0,
    this.totalSteps = 6,
    required this.profileDraft,
    this.healthPermissionGranted = false,
    this.calendarPermissionGranted = false,
    this.notificationPermissionGranted = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    UserProfile? profileDraft,
    bool? healthPermissionGranted,
    bool? calendarPermissionGranted,
    bool? notificationPermissionGranted,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      profileDraft: profileDraft ?? this.profileDraft,
      healthPermissionGranted: healthPermissionGranted ?? this.healthPermissionGranted,
      calendarPermissionGranted: calendarPermissionGranted ?? this.calendarPermissionGranted,
      notificationPermissionGranted: notificationPermissionGranted ?? this.notificationPermissionGranted,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingController(this._ref)
      : super(OnboardingState(profileDraft: UserProfile.initialGuest()));

  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setGoal(String goal) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(primaryGoal: goal),
    );
    nextStep();
  }

  void updateProfile({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(
        name: name,
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
      ),
    );
  }

  void updatePreferences({
    int? dailyFreeMinutes,
    String? preferredWorkoutPlace,
  }) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(
        dailyFreeMinutes: dailyFreeMinutes,
        preferredWorkoutPlace: preferredWorkoutPlace,
      ),
    );
  }

  void togglePermission(String type, bool granted) {
    if (type == 'health') {
      state = state.copyWith(healthPermissionGranted: granted);
    } else if (type == 'calendar') {
      state = state.copyWith(calendarPermissionGranted: granted);
    } else if (type == 'notification') {
      state = state.copyWith(notificationPermissionGranted: granted);
    }
  }

  void toggleCycleTracking(bool enabled) {
    state = state.copyWith(
      profileDraft: state.profileDraft.copyWith(cycleTrackingEnabled: enabled),
    );
  }

  Future<void> completeOnboarding() async {
    final finalProfile = state.profileDraft.copyWith(onboardingCompleted: true);
    await _ref.read(authControllerProvider.notifier).updateProfile(finalProfile);
    await _ref.read(authControllerProvider.notifier).completeOnboarding();
  }
}

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref);
});
