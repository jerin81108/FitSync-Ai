import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '20');
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '65');

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if step 5 (cycle) should be skipped if male
    final isMale = state.profileDraft.gender == 'male';
    final effectiveTotalSteps = isMale ? 5 : 6;
    final progress = (state.currentStep + 1) / effectiveTotalSteps;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: state.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => controller.previousStep(),
              )
            : null,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepTeal),
            minHeight: 6,
          ),
        ),
        actions: [
          if (state.currentStep > 0)
            TextButton(
              onPressed: () async {
                await controller.completeOnboarding();
                widget.onCompleted();
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: _buildCurrentStep(state, controller, isDark),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(OnboardingState state, OnboardingController controller, bool isDark) {
    switch (state.currentStep) {
      case 0:
        return _buildStepWelcome(state, controller, isDark);
      case 1:
        return _buildStepGoal(state, controller, isDark);
      case 2:
        return _buildStepProfile(state, controller, isDark);
      case 3:
        return _buildStepPreferences(state, controller, isDark);
      case 4:
        return _buildStepPermissions(state, controller, isDark);
      case 5:
        return _buildStepCycle(state, controller, isDark);
      default:
        return _buildStepWelcome(state, controller, isDark);
    }
  }

  // --- STEP 0: WELCOME ---
  Widget _buildStepWelcome(OnboardingState state, OnboardingController controller, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.deepTeal.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🌿', style: TextStyle(fontSize: 54)),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'FitSync AI',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : AppColors.deepTeal,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Fitness that fits your life.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.warmCoral,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No robot targets. No broken streaks. When exams, stress, or low sleep get in the way, your target adapts automatically with zero guilt.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => controller.nextStep(),
          child: const Text('Get Started (under 60s)'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- STEP 1: PICK GOAL ---
  Widget _buildStepGoal(OnboardingState state, OnboardingController controller, bool isDark) {
    final goals = [
      ('stay_active', 'Stay Active', 'Gentle consistency without burnout', '🌱'),
      ('lose_weight', 'Lose Weight', 'Sustainable deficit & adapted burns', '🔥'),
      ('build_strength', 'Build Strength', 'Progressive bodyweight & gym tone', '💪'),
      ('reduce_stress', 'Reduce Stress', 'Nervous system resets & calm energy', '🧘'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your main focus?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'FitSync AI will calibrate routine recommendations accordingly.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: goals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final g = goals[index];
              final isSelected = state.profileDraft.primaryGoal == g.$1;

              return GlassCard(
                onTap: () => controller.setGoal(g.$1),
                backgroundColor: isSelected
                    ? AppColors.deepTeal.withValues(alpha: 0.12)
                    : (isDark ? AppColors.darkCard : Colors.white),
                border: BorderSide(
                  color: isSelected ? AppColors.deepTeal : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                  width: isSelected ? 2.0 : 1.0,
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Text(g.$4, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.$2,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white : AppColors.lightTextPrimary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            g.$3,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.deepTeal, size: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- STEP 2: BASIC PROFILE ---
  Widget _buildStepProfile(OnboardingState state, OnboardingController controller, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Used strictly for baseline calories and age-appropriate scaling.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Name
          const Text('Your Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'e.g. Alex or Athira'),
            onChanged: (val) => controller.updateProfile(name: val.trim()),
          ),
          const SizedBox(height: 16),

          // Age & Gender
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age (DPDP 18+)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '20'),
                      onChanged: (val) => controller.updateProfile(age: int.tryParse(val) ?? 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weight (kg)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '65'),
                      onChanged: (val) => controller.updateProfile(weightKg: double.tryParse(val) ?? 65.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gender Selector Chips
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildGenderChip('male', 'Male', state, controller),
              _buildGenderChip('female', 'Female', state, controller),
              _buildGenderChip('non_binary', 'Non-binary', state, controller),
              _buildGenderChip('prefer_not_to_say', 'Prefer not to say', state, controller),
            ],
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () => controller.nextStep(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String val, String label, OnboardingState state, OnboardingController controller) {
    final isSelected = state.profileDraft.gender == val;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) controller.updateProfile(gender: val);
      },
      selectedColor: AppColors.deepTeal.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepTeal : AppColors.lightTextSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  // --- STEP 3: PREFERENCES ---
  Widget _buildStepPreferences(OnboardingState state, OnboardingController controller, bool isDark) {
    final times = [15, 30, 45, 60];
    final places = [('indoor', 'Indoor'), ('outdoor', 'Outdoor'), ('both', 'Both')];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Availability & Space',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'How much time can you comfortably commit on normal days?',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 24),

        const Text('Usual free time per day', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: times.map((mins) {
            final isSelected = state.profileDraft.dailyFreeMinutes == mins;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GlassCard(
                  onTap: () => controller.updatePreferences(dailyFreeMinutes: mins),
                  backgroundColor: isSelected ? AppColors.deepTeal.withValues(alpha: 0.15) : null,
                  border: BorderSide(
                    color: isSelected ? AppColors.deepTeal : Colors.transparent,
                    width: 2.0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '$mins min',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.deepTeal : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        const Text('Preferred Workout Place', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          children: places.map((p) {
            final isSelected = state.profileDraft.preferredWorkoutPlace == p.$1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GlassCard(
                  onTap: () => controller.updatePreferences(preferredWorkoutPlace: p.$1),
                  backgroundColor: isSelected ? AppColors.deepTeal.withValues(alpha: 0.15) : null,
                  border: BorderSide(
                    color: isSelected ? AppColors.deepTeal : Colors.transparent,
                    width: 2.0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      p.$2,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.deepTeal : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => controller.nextStep(),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  // --- STEP 4: PERMISSIONS ---
  Widget _buildStepPermissions(OnboardingState state, OnboardingController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect Your Life',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Every permission has a plain reason. You can choose "Not now" and use manual entry anytime.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 20),

        _buildPermissionTile(
          icon: Icons.favorite,
          title: 'Health Data (Steps & Sleep)',
          reason: 'Pulls sleep duration and daily steps so your score is automatic with no wearable required.',
          granted: state.healthPermissionGranted,
          onToggle: (val) => controller.togglePermission('health', val),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        _buildPermissionTile(
          icon: Icons.calendar_month,
          title: 'Calendar (Read-Only)',
          reason: 'Auto-detects exams, vivas, and deadlines to lower your target ahead of stressful days.',
          granted: state.calendarPermissionGranted,
          onToggle: (val) => controller.togglePermission('calendar', val),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        _buildPermissionTile(
          icon: Icons.notifications_active,
          title: 'Morning Booster Notifications',
          reason: 'Delivers your 1-sentence motivation and readiness forecast at your wake time. Never spams.',
          granted: state.notificationPermissionGranted,
          onToggle: (val) => controller.togglePermission('notification', val),
          isDark: isDark,
        ),
        const Spacer(),

        ElevatedButton(
          onPressed: () async {
            if (state.profileDraft.gender == 'female') {
              controller.nextStep();
            } else {
              await controller.completeOnboarding();
              widget.onCompleted();
            }
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String reason,
    required bool granted,
    required ValueChanged<bool> onToggle,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepTeal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: granted,
            onChanged: onToggle,
            activeThumbColor: AppColors.deepTeal,
          ),
        ],
      ),
    );
  }

  // --- STEP 5: OPTIONAL CYCLE TRACKING ---
  Widget _buildStepCycle(OnboardingState state, OnboardingController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cycle & Hormonal Sync',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Natural energy swings are real. FitSync AI adapts targets around your cycle phases.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 24),

        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Enable Cycle Sync Engine',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Switch(
                    value: state.profileDraft.cycleTrackingEnabled,
                    onChanged: (val) => controller.toggleCycleTracking(val),
                    activeThumbColor: AppColors.warmCoral,
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                '• Automatically softens intensity on Days 1–3 of period\n'
                '• Swaps heavy cardio for cramp-relief flows and mobility\n'
                '• Supports PCOS/PCOD low-cortisol somatic pacing\n'
                '• Privacy first: Encrypted on-device, zero ad tracking',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.lightTextSecondary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'FitSync AI is not a medical device. It does not diagnose or treat any medical conditions.',
                  style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        ElevatedButton(
          onPressed: () async {
            await controller.completeOnboarding();
            widget.onCompleted();
          },
          child: const Text('Start My Journey (Zero Guilt)'),
        ),
      ],
    );
  }
}
