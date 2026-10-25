/// User Profile model representing athlete profile, preferences, and permissions
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String gender; // 'male', 'female', 'non_binary', 'prefer_not_to_say'
  final double heightCm;
  final double weightKg;
  final String primaryGoal; // 'stay_active', 'lose_weight', 'build_strength', 'reduce_stress'
  final int dailyFreeMinutes;
  final String preferredWorkoutPlace; // 'indoor', 'outdoor', 'both'
  final bool cycleTrackingEnabled;
  final String tonePreference; // 'friendly', 'calm', 'playful'
  final String preferredNotificationTime; // e.g. '07:30'
  final String preferredLanguage; // 'en', 'ta', 'hi'
  final bool isPremium;
  final bool onboardingCompleted;

  const UserProfile({
    required this.id,
    required this.name,
    this.age = 21,
    this.gender = 'prefer_not_to_say',
    this.heightCm = 170.0,
    this.weightKg = 65.0,
    this.primaryGoal = 'stay_active',
    this.dailyFreeMinutes = 45,
    this.preferredWorkoutPlace = 'both',
    this.cycleTrackingEnabled = false,
    this.tonePreference = 'friendly',
    this.preferredNotificationTime = '07:30',
    this.preferredLanguage = 'en',
    this.isPremium = false,
    this.onboardingCompleted = false,
  });

  factory UserProfile.initialGuest() {
    return const UserProfile(
      id: 'guest_user',
      name: 'Athlete',
      age: 20,
      gender: 'prefer_not_to_say',
      heightCm: 168.0,
      weightKg: 62.0,
      primaryGoal: 'stay_active',
      dailyFreeMinutes: 45,
      preferredWorkoutPlace: 'both',
      cycleTrackingEnabled: false,
      tonePreference: 'friendly',
      preferredNotificationTime: '07:30',
      preferredLanguage: 'en',
      isPremium: false,
      onboardingCompleted: false,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? primaryGoal,
    int? dailyFreeMinutes,
    String? preferredWorkoutPlace,
    bool? cycleTrackingEnabled,
    String? tonePreference,
    String? preferredNotificationTime,
    String? preferredLanguage,
    bool? isPremium,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      dailyFreeMinutes: dailyFreeMinutes ?? this.dailyFreeMinutes,
      preferredWorkoutPlace: preferredWorkoutPlace ?? this.preferredWorkoutPlace,
      cycleTrackingEnabled: cycleTrackingEnabled ?? this.cycleTrackingEnabled,
      tonePreference: tonePreference ?? this.tonePreference,
      preferredNotificationTime: preferredNotificationTime ?? this.preferredNotificationTime,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isPremium: isPremium ?? this.isPremium,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'primary_goal': primaryGoal,
    'daily_free_minutes': dailyFreeMinutes,
    'preferred_workout_place': preferredWorkoutPlace,
    'cycle_tracking_enabled': cycleTrackingEnabled,
    'tone_preference': tonePreference,
    'preferred_notification_time': preferredNotificationTime,
    'preferred_language': preferredLanguage,
    'is_premium': isPremium,
    'onboarding_completed': onboardingCompleted,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'guest_user',
      name: json['name'] as String? ?? 'Athlete',
      age: (json['age'] as num?)?.toInt() ?? 21,
      gender: json['gender'] as String? ?? 'prefer_not_to_say',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 65.0,
      primaryGoal: json['primary_goal'] as String? ?? 'stay_active',
      dailyFreeMinutes: (json['daily_free_minutes'] as num?)?.toInt() ?? 45,
      preferredWorkoutPlace: json['preferred_workout_place'] as String? ?? 'both',
      cycleTrackingEnabled: json['cycle_tracking_enabled'] as bool? ?? false,
      tonePreference: json['tone_preference'] as String? ?? 'friendly',
      preferredNotificationTime: json['preferred_notification_time'] as String? ?? '07:30',
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      isPremium: json['is_premium'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }
}
