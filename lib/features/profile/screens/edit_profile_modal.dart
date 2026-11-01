import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/female_health_state.dart';
import '../../../core/models/user_profile.dart';
import '../../auth/auth_controller.dart';
import '../../female_health/female_health_controller.dart';

/// Modal to edit athlete profile settings including Gender, Biometrics, and Preferences
class EditProfileModal extends ConsumerStatefulWidget {
  const EditProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }

  @override
  ConsumerState<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<EditProfileModal> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  late String _selectedGoal;
  late String _selectedGender;
  late String _selectedPlace;
  late int _selectedMinutes;
  late String _selectedLanguage;
  late String _selectedTone;

  // Female health local state inside modal
  late bool _cycleTrackingEnabled;
  late CyclePhase _selectedCyclePhase;
  late bool _pcosMode;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authControllerProvider).user ?? UserProfile.initialGuest();
    final femaleState = ref.read(femaleHealthControllerProvider);

    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: '${profile.age}');
    _heightController = TextEditingController(text: '${profile.heightCm.round()}');
    _weightController = TextEditingController(text: '${profile.weightKg.round()}');

    _selectedGoal = profile.primaryGoal;
    _selectedGender = profile.gender;
    _selectedPlace = profile.preferredWorkoutPlace;
    _selectedMinutes = profile.dailyFreeMinutes;
    _selectedLanguage = profile.preferredLanguage;
    _selectedTone = profile.tonePreference;

    _cycleTrackingEnabled = femaleState.isCycleTrackingEnabled;
    _selectedCyclePhase = femaleState.currentPhase;
    _pcosMode = femaleState.isPcosPcodMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final authController = ref.read(authControllerProvider.notifier);
    final current = ref.read(authControllerProvider).user ?? UserProfile.initialGuest();

    final isFemale = _selectedGender == 'female';
    final shouldTrackCycle = isFemale && _cycleTrackingEnabled;

    final updated = current.copyWith(
      name: _nameController.text.trim().isEmpty ? 'Athlete' : _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? current.age,
      heightCm: double.tryParse(_heightController.text.trim()) ?? current.heightCm,
      weightKg: double.tryParse(_weightController.text.trim()) ?? current.weightKg,
      primaryGoal: _selectedGoal,
      gender: _selectedGender,
      cycleTrackingEnabled: shouldTrackCycle,
      preferredWorkoutPlace: _selectedPlace,
      dailyFreeMinutes: _selectedMinutes,
      preferredLanguage: _selectedLanguage,
      tonePreference: _selectedTone,
    );

    authController.updateProfile(updated);

    // Sync with Female Health Controller
    final femaleNotifier = ref.read(femaleHealthControllerProvider.notifier);
    if (isFemale) {
      femaleNotifier.toggleCycleTracking(shouldTrackCycle);
      if (shouldTrackCycle) {
        femaleNotifier.setPhase(_selectedCyclePhase);
        femaleNotifier.togglePcosMode(_pcosMode);
      }
    } else {
      femaleNotifier.toggleCycleTracking(false);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profile settings and preferences updated successfully!'),
        backgroundColor: AppColors.deepTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.deepTeal.withValues(alpha: 0.25),
                            AppColors.mintAccent.withValues(alpha: 0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('⚙️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Gender, biometrics & workout calibration',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 20),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              children: [
                // 1. Name Field
                _buildSectionHeader('Full Name / Athlete Tag', '👤'),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Jerin / Athlete',
                    prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.deepTeal),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Gender Selection (Requested Option)
                _buildSectionHeader('Gender', '⚧️'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ('male', '👨 Male'),
                    ('female', '👩 Female'),
                    ('non_binary', '🧑 Non-Binary'),
                    ('prefer_not_to_say', '🔒 Prefer not to say'),
                  ].map((g) {
                    final isSelected = _selectedGender == g.$1;
                    return ChoiceChip(
                      label: Text(g.$2),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedGender = g.$1;
                            if (g.$1 == 'female') {
                              _cycleTrackingEnabled = true;
                            }
                          });
                        }
                      },
                      selectedColor: g.$1 == 'female'
                          ? AppColors.warmCoral.withValues(alpha: 0.2)
                          : AppColors.deepTeal.withValues(alpha: 0.2),
                      side: BorderSide(
                        color: isSelected
                            ? (g.$1 == 'female' ? AppColors.warmCoral : AppColors.deepTeal)
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (g.$1 == 'female' ? AppColors.warmCoral : AppColors.deepTeal)
                            : null,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Female Health Sync Sub-card (Unlocked when Female is chosen)
                if (_selectedGender == 'female') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warmCoral.withValues(alpha: 0.12),
                          Colors.purple.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.warmCoral.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🌸', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Female Health & Cycle Sync',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.warmCoral),
                              ),
                            ),
                            Switch(
                              value: _cycleTrackingEnabled,
                              onChanged: (val) => setState(() => _cycleTrackingEnabled = val),
                              activeColor: AppColors.warmCoral,
                            ),
                          ],
                        ),
                        if (_cycleTrackingEnabled) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Day 1-3 automatically scales down targets to cramp-relief & low fatigue routines.',
                            style: TextStyle(fontSize: 11, height: 1.3),
                          ),
                          const SizedBox(height: 12),
                          const Text('Current Phase:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: CyclePhase.values.map((phase) {
                              final isSelected = _selectedCyclePhase == phase;
                              return ChoiceChip(
                                label: Text(phase.label, style: const TextStyle(fontSize: 11)),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedCyclePhase = phase);
                                },
                                selectedColor: AppColors.warmCoral.withValues(alpha: 0.25),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('PCOS / PCOD Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              Switch(
                                value: _pcosMode,
                                onChanged: (val) => setState(() => _pcosMode = val),
                                activeColor: AppColors.warmCoral,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 3. Biometrics Row (Age, Height, Weight)
                _buildSectionHeader('Biometrics', '📊'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildBiometricField(
                        controller: _ageController,
                        label: 'Age',
                        unit: 'yrs',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBiometricField(
                        controller: _heightController,
                        label: 'Height',
                        unit: 'cm',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBiometricField(
                        controller: _weightController,
                        label: 'Weight',
                        unit: 'kg',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4. Primary Goal
                _buildSectionHeader('Primary Goal', '🎯'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ('stay_active', '🏃 Stay Active'),
                    ('lose_weight', '🔥 Lose Weight'),
                    ('build_strength', '💪 Build Strength'),
                    ('reduce_stress', '🧘 Reduce Stress'),
                  ].map((g) {
                    final isSelected = _selectedGoal == g.$1;
                    return ChoiceChip(
                      label: Text(g.$2),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedGoal = g.$1);
                      },
                      selectedColor: AppColors.deepTeal.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white12 : Colors.black12),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.deepTeal : null,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // 5. Workout Setting Preference
                _buildSectionHeader('Preferred Workout Setting', '📍'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ('indoor', '🏠 Indoor'),
                    ('outdoor', '🌳 Outdoor'),
                    ('both', '⚡ Both'),
                  ].map((p) {
                    final isSelected = _selectedPlace == p.$1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(p.$2, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedPlace = p.$1);
                          },
                          selectedColor: AppColors.deepTeal.withValues(alpha: 0.18),
                          side: BorderSide(
                            color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white12 : Colors.black12),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.deepTeal : null,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // 6. Daily Available Minutes
                _buildSectionHeader('Daily Free Minutes', '⏱️'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [15, 30, 45, 60].map((min) {
                    final isSelected = _selectedMinutes == min;
                    return ChoiceChip(
                      label: Text('$min min'),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedMinutes = min);
                      },
                      selectedColor: AppColors.warmCoral.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: isSelected ? AppColors.warmCoral : (isDark ? Colors.white12 : Colors.black12),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.warmCoral : null,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // 7. Language Preference
                _buildSectionHeader('AI Coach Language & Tone', '🗣️'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ('en', 'English 🇬🇧'),
                    ('ta', 'தமிழ் / Tanglish 🇮🇳'),
                    ('hi', 'हिन्दी 🇮🇳'),
                  ].map((lang) {
                    final isSelected = _selectedLanguage == lang.$1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(lang.$2, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedLanguage = lang.$1);
                          },
                          selectedColor: AppColors.mintAccent.withValues(alpha: 0.2),
                          side: BorderSide(
                            color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white12 : Colors.black12),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.deepTeal : null,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // 8. Mindset & Coaching Philosophy Focus
                _buildSectionHeader('Mindset & Mental Compass', '🧠'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ('friendly', '🌿 Self-Compassionate (No-Guilt)'),
                    ('calm', '🏛️ Stoic Balance (Consistent & Calm)'),
                    ('playful', '🚀 High Energy (Dynamic Momentum)'),
                  ].map((m) {
                    final isSelected = _selectedTone == m.$1;
                    return ChoiceChip(
                      label: Text(m.$2, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedTone = m.$1);
                      },
                      selectedColor: AppColors.deepTeal.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white12 : Colors.black12),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.deepTeal : null,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 26),

                // Save Button with subtle glow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepTeal.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Profile Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }

  Widget _buildBiometricField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ($unit)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
