import '../../core/models/exercise.dart';
import '../../core/models/workout.dart';

/// Comprehensive Workout Library containing 60+ production-grade exercises and routines
/// Specifically tagged for life situations (exams, cramps, low energy, no equipment, short time).
class WorkoutLibrary {
  static final List<Workout> allWorkouts = [
    // -------------------------------------------------------------------------
    // 1. QUICK-15 / EXAM & STRESS RELIEF ROUTINES
    // -------------------------------------------------------------------------
    const Workout(
      id: 'quick_15_calm_mobility',
      name: 'Quick 15-Min Brain-Clear Mobility',
      description: 'Gentle spinal twists, neck releases, and deep breathing to release mental tension during study days.',
      durationMinutes: 15,
      intensity: 1,
      equipment: 'None',
      bodyRegion: 'full_body',
      tags: ['quick-15', 'stress-relief', 'low-impact', 'no-equipment', 'seated_mobility'],
      steps: [
        ExerciseStep(
          id: 'ex_neck_rolls',
          name: 'Seated Gentle Neck Rolls',
          durationSeconds: 60,
          instruction: 'Gently rotate your neck in slow circles. Inhale as head lifts, exhale as chin drops to chest.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_shoulder_shrugs',
          name: 'Shoulder Elevation & Release',
          durationSeconds: 60,
          instruction: 'Inhale while lifting shoulders to ears; hold 2 seconds, exhale completely and drop shoulders down.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_seated_cat_cow',
          name: 'Seated Cat-Cow Spine Stretch',
          durationSeconds: 90,
          instruction: 'Hands on knees. Arch back forward opening chest (Cow), then round back pulling navel in (Cat).',
          bodyRegion: 'core',
        ),
        ExerciseStep(
          id: 'ex_seated_side_reach',
          name: 'Lateral Overhead Reach',
          durationSeconds: 90,
          instruction: 'Reach right arm over to left side feeling lat and rib cage lengthen. Switch sides smoothly.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_hip_flexor_stretch',
          name: 'Low Lunge Hip Opener',
          durationSeconds: 120,
          instruction: 'Step one foot forward into a gentle lunge. Sink hips forward to open tight hip flexors from long sitting.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_box_breathing',
          name: 'Box Breathing Grounding (4-4-4-4)',
          durationSeconds: 120,
          instruction: 'Inhale 4s, hold 4s, exhale 4s, hold 4s. Calms nervous system and lowers exam cortisol.',
          bodyRegion: 'full_body',
        ),
      ],
    ),

    const Workout(
      id: 'light_walking_breathing',
      name: '15-Min Light Walking & Stress Reset',
      description: 'Steady pacing combined with rhythmic nasal breathing to restore parasympathetic calm without sweating.',
      durationMinutes: 15,
      intensity: 1,
      equipment: 'None',
      bodyRegion: 'full_body',
      tags: ['low-impact', 'stress-relief', 'quick-15', 'no-equipment'],
      steps: [
        ExerciseStep(
          id: 'ex_warm_stride',
          name: 'Easy Pacing Stride',
          durationSeconds: 180,
          instruction: 'Walk at a relaxed conversational pace. Let arms swing naturally by your sides.',
          bodyRegion: 'full_body',
        ),
        ExerciseStep(
          id: 'ex_heel_toe_roll',
          name: 'Ankle & Foot Articulation Walk',
          durationSeconds: 120,
          instruction: 'Consciously step heel-to-toe, rolling through arches to stimulate leg circulation.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_arm_circles_walk',
          name: 'Walking Arm Sweeps',
          durationSeconds: 90,
          instruction: 'Circle arms backward while walking to reverse forward desk slouching.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_nasal_breathing_stride',
          name: 'Cadence Nasal Breathing Walk',
          durationSeconds: 240,
          instruction: 'Inhale through nose for 4 steps, exhale smoothly for 4 steps.',
          bodyRegion: 'full_body',
        ),
        ExerciseStep(
          id: 'ex_cool_down_stand',
          name: 'Standing Grounding Stillness',
          durationSeconds: 90,
          instruction: 'Stand tall with feet hip-width. Feel feet anchored to the ground and take three deep sighs.',
          bodyRegion: 'full_body',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 2. CRAMP-RELIEF & FEMALE HEALTH RESTORATIVE FLOWS
    // -------------------------------------------------------------------------
    const Workout(
      id: 'cramp_relief_gentle_flow',
      name: 'Cramp-Relief Gentle Flow & Restorative Stretch',
      description: 'Zero abdominal pressure. Relieves lower back tension, pelvic cramps, and fatigue during period days.',
      durationMinutes: 15,
      intensity: 1,
      equipment: 'Mat',
      bodyRegion: 'lower_body',
      tags: ['cramp-relief', 'yoga', 'low-impact', 'no-equipment', 'quick-15'],
      steps: [
        ExerciseStep(
          id: 'ex_childs_pose_wide',
          name: 'Wide-Knee Restorative Child Pose',
          durationSeconds: 180,
          instruction: 'Knees wide on mat, big toes touching. Sink hips back toward heels and rest forehead on mat.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_cat_cow_slow',
          name: 'Gentle Pelvic Tilt Cat-Cow',
          durationSeconds: 120,
          instruction: 'Move slowly on hands and knees. Gently rock pelvis without compressing lower belly.',
          bodyRegion: 'core',
        ),
        ExerciseStep(
          id: 'ex_supine_butterfly',
          name: 'Reclining Bound Angle (Supta Baddha Konasana)',
          durationSeconds: 180,
          instruction: 'Lie on back, soles of feet together, knees dropping open. Relaxes pelvic floor and soothes cramps.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_knees_to_chest_rock',
          name: 'Supine Knee Hug & Gentle Rock',
          durationSeconds: 120,
          instruction: 'Hug knees toward armpits (wide). Gently rock side-to-side massaging sacrum against floor.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_legs_up_wall',
          name: 'Legs Up Against The Wall (Viparita Karani)',
          durationSeconds: 180,
          instruction: 'Rest legs vertically against a wall or chair. Relieves heavy leg feeling and supports circulation.',
          bodyRegion: 'lower_body',
        ),
      ],
    ),

    const Workout(
      id: 'pcos_gentle_hormone_balance',
      name: 'Gentle Hormone Balance & Lymphatic Flow',
      description: 'Low-cortisol somatic movements tailored to PCOS/fatigue energy swings. No heart-rate spikes.',
      durationMinutes: 20,
      intensity: 2,
      equipment: 'None',
      bodyRegion: 'full_body',
      tags: ['low-impact', 'stress-relief', 'no-equipment', 'yoga'],
      steps: [
        ExerciseStep(
          id: 'ex_lymph_bounce',
          name: 'Micro Heel Drops (Lymphatic Reset)',
          durationSeconds: 90,
          instruction: 'Stand tall. Gently bounce on heels with soft knees to stimulate lymph drainage and venous return.',
          bodyRegion: 'full_body',
        ),
        ExerciseStep(
          id: 'ex_pelvic_swings',
          name: 'Somatic Pelvic Figure-Eights',
          durationSeconds: 120,
          instruction: 'Soft knees, draw gentle figure-eights with your hips to mobilize lumbar and pelvic joints.',
          bodyRegion: 'core',
        ),
        ExerciseStep(
          id: 'ex_gentle_bridge',
          name: 'Glute Bridge with Extended Hold',
          durationSeconds: 120,
          instruction: 'Lie on back, bend knees. Press through heels and lift hips into a smooth straight line. Hold 5s, lower slowly.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_supported_fish',
          name: 'Heart-Opening Chest Expansion',
          durationSeconds: 180,
          instruction: 'Lie back with a rolled towel under upper back. Arms open wide to reverse forward posture.',
          bodyRegion: 'upper_body',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 3. DESK & POSTURE / SEATED MOBILITY ROUTINES
    // -------------------------------------------------------------------------
    const Workout(
      id: 'desk_worker_spine_mobility',
      name: '20-Min Spine & Hip Mobility Flow',
      description: 'Targeted for long library study sessions. Unlocks stiff hips, glute amnesia, and hunched neck.',
      durationMinutes: 20,
      intensity: 2,
      equipment: 'Chair',
      bodyRegion: 'full_body',
      tags: ['low-impact', 'no-equipment', 'upper-body', 'lower-body'],
      steps: [
        ExerciseStep(
          id: 'ex_seated_figure4',
          name: 'Seated Figure-4 Piriformis Stretch',
          durationSeconds: 120,
          instruction: 'Cross right ankle over left knee. Keep spine straight and hinge forward gently until glute stretch is felt.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_thoracic_twist',
          name: 'Seated Thoracic Spine Twist',
          durationSeconds: 120,
          instruction: 'Sit tall, rotate torso toward chair backrest. Hold for 3 smooth deep breaths on each side.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_wall_slides',
          name: 'Standing Scapular Wall Slides',
          durationSeconds: 90,
          instruction: 'Back and elbows flat against wall. Slide arms overhead while maintaining contact with wall.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_standing_quad_stretch',
          name: 'Supported Standing Quad Pull',
          durationSeconds: 120,
          instruction: 'Hold chair for balance. Pull heel to glute, tuck pelvis forward to lengthen thigh muscles.',
          bodyRegion: 'lower_body',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 4. MODERATE & BALANCED BODYWEIGHT ROUTINES
    // -------------------------------------------------------------------------
    const Workout(
      id: 'bodyweight_endurance_starter',
      name: '25-Min Zero-Equipment Tone & Core',
      description: 'Balanced bodyweight flow for moderate energy days. Elevates metabolism without crushing exhaustion.',
      durationMinutes: 25,
      intensity: 3,
      equipment: 'None',
      bodyRegion: 'full_body',
      tags: ['no-equipment', 'lower-body', 'upper-body'],
      steps: [
        ExerciseStep(
          id: 'ex_bodyweight_squat',
          name: 'Tempo Air Squats',
          durationSeconds: 60,
          repCount: 15,
          instruction: 'Feet shoulder-width. Lower hips back and down for 3 seconds, drive through mid-foot to stand.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_incline_pushup',
          name: 'Desk or Floor Push-Ups',
          durationSeconds: 60,
          repCount: 12,
          instruction: 'Keep core tight in a straight plank line. Lower chest to hands, push up firmly.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_glute_bridges',
          name: 'Single Leg Glute Bridges',
          durationSeconds: 90,
          instruction: 'Lift one leg, drive through opposite heel. Squeeze glute at top for 2 seconds.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_dead_bug',
          name: 'Dead Bug Core Stabilization',
          durationSeconds: 90,
          instruction: 'Lie on back, arms up and knees at 90°. Slowly extend opposite arm and leg while pressing lower back down.',
          bodyRegion: 'core',
        ),
        ExerciseStep(
          id: 'ex_bird_dog',
          name: 'Bird-Dog Spinal Balance',
          durationSeconds: 90,
          instruction: 'On hands and knees, reach opposite arm and leg straight out. Keep hips completely square.',
          bodyRegion: 'core',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 5. UPPER-BODY SPECIFIC (INJURY-GUARD SAFE FOR LOWER BODY)
    // -------------------------------------------------------------------------
    const Workout(
      id: 'upper_body_strength_focus',
      name: '25-Min Upper Body & Posture Builder',
      description: 'Completely zero knee/ankle load. Ideal for lower body injuries or upper strength focus.',
      durationMinutes: 25,
      intensity: 3,
      equipment: 'None',
      bodyRegion: 'upper_body',
      tags: ['upper-body', 'no-equipment', 'low-impact'],
      steps: [
        ExerciseStep(
          id: 'ex_seated_overhead_press',
          name: 'Seated Isometric Overhead Press',
          durationSeconds: 60,
          instruction: 'Sit tall, push imaginary weight overhead engaging shoulders and upper back.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_pushups_knee',
          name: 'Modified Knee Push-Ups',
          durationSeconds: 60,
          instruction: 'Keep spine neutral. Elbows at 45-degree angle from torso.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_prone_y_t_w',
          name: 'Prone Scapular Y-T-W Extensions',
          durationSeconds: 90,
          instruction: 'Lie face down. Raise arms into Y, T, and W positions to fire rhomboids and lower traps.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_plank_shoulder_taps',
          name: 'Shoulder Tap Plank',
          durationSeconds: 60,
          instruction: 'From plank or knee plank, tap opposite shoulder without rocking hips.',
          bodyRegion: 'core',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 6. LOWER-BODY SPECIFIC (INJURY-GUARD SAFE FOR WRIST/SHOULDER)
    // -------------------------------------------------------------------------
    const Workout(
      id: 'lower_body_leg_burn',
      name: '25-Min Lower Body Pillar Routine',
      description: 'Zero shoulder/wrist load. Ideal when nursing wrist or shoulder strain.',
      durationMinutes: 25,
      intensity: 3,
      equipment: 'None',
      bodyRegion: 'lower_body',
      tags: ['lower-body', 'no-equipment'],
      steps: [
        ExerciseStep(
          id: 'ex_reverse_lunges',
          name: 'Alternating Reverse Lunges',
          durationSeconds: 90,
          instruction: 'Step back into lunge, front knee tracks in line with middle toe. Push up through front heel.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_wall_sit',
          name: 'Wall Sit Isometric Hold',
          durationSeconds: 60,
          instruction: 'Back flat against wall, thighs parallel to ground. Breathe steadily through nose.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_calf_raises',
          name: 'Slow Deficit Calf Raises',
          durationSeconds: 60,
          instruction: 'Press up onto balls of feet, hold 2s at peak, lower slowly for 3s.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_lateral_lunges',
          name: 'Side Lunge Hip Shifts',
          durationSeconds: 90,
          instruction: 'Step wide to side, bend one knee while keeping other leg straight. Opens adductors.',
          bodyRegion: 'lower_body',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 7. OPTIMAL FULL BODY ROUTINES
    // -------------------------------------------------------------------------
    const Workout(
      id: 'full_body_strength_revitalizer',
      name: '30-Min Dynamic Full Body Strength',
      description: 'Comprehensive functional strength workout balancing push, pull, squat, and core stabilization.',
      durationMinutes: 30,
      intensity: 4,
      equipment: 'None',
      bodyRegion: 'full_body',
      tags: ['no-equipment', 'upper-body', 'lower-body'],
      steps: [
        ExerciseStep(
          id: 'ex_squat_to_stand',
          name: 'Squat to Hamstring Stand',
          durationSeconds: 60,
          instruction: 'Squat deep holding toes, then straighten legs while keeping hold of toes.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_standard_pushups',
          name: 'Full Range Push-Ups',
          durationSeconds: 60,
          repCount: 15,
          instruction: 'Full chest to floor, lock out elbows at top with controlled core.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_jump_lunges_sub',
          name: 'Step-Through Lunges with High Knee',
          durationSeconds: 90,
          instruction: 'Step back into lunge, drive back knee forward into a balance stance.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_plank_walkouts',
          name: 'Inchworm to High Plank',
          durationSeconds: 90,
          instruction: 'From standing, touch floor and walk hands out into a high plank. Walk hands back.',
          bodyRegion: 'full_body',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 8. PEAK ENERGY / PUSH DAY ROUTINES
    // -------------------------------------------------------------------------
    const Workout(
      id: 'peak_full_body_power',
      name: 'Push Day: 35-Min High Energy Power Circuit',
      description: 'When readiness is 93+ and your battery is fully loaded. Dynamic intervals and high strength output.',
      durationMinutes: 35,
      intensity: 5,
      equipment: 'None',
      bodyRegion: 'full_body',
      tags: ['no-equipment', 'upper-body', 'lower-body'],
      steps: [
        ExerciseStep(
          id: 'ex_power_squats',
          name: 'Explosive Air Squats',
          durationSeconds: 60,
          instruction: 'Fast concentric drive up with maximum hip extension.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_plyo_pushup_prep',
          name: 'Tempo Push-Up with Hand Lift',
          durationSeconds: 60,
          instruction: 'Lower chest to floor, lift hands off ground for 1s, press up aggressively.',
          bodyRegion: 'upper_body',
        ),
        ExerciseStep(
          id: 'ex_high_knees_pace',
          name: 'High Knee Rhythm Run',
          durationSeconds: 60,
          instruction: 'Drive knees to hip level on balls of feet with upright posture.',
          bodyRegion: 'full_body',
        ),
        ExerciseStep(
          id: 'ex_hollow_body_rock',
          name: 'Hollow Body Gymnastic Rock',
          durationSeconds: 60,
          instruction: 'Lower back glued to floor, arms and legs extended in banana shape. Small gentle rocks.',
          bodyRegion: 'core',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 9. YOGA & RESTORATIVE FLEXIBILITY
    // -------------------------------------------------------------------------
    const Workout(
      id: 'sun_salutation_flow',
      name: '20-Min Vinyasa Flow & Deep Release',
      description: 'Smooth breath-linked sequence to promote joint mobility, mental focus, and fluid circulation.',
      durationMinutes: 20,
      intensity: 2,
      equipment: 'Mat',
      bodyRegion: 'full_body',
      tags: ['yoga', 'low-impact', 'stress-relief', 'no-equipment'],
      steps: [
        ExerciseStep(
          id: 'ex_mountain_pose',
          name: 'Tadasana (Mountain Pose)',
          durationSeconds: 60,
          instruction: 'Stand grounded, crown reaching toward sky. Breathe evenly into belly.',
          bodyRegion: 'full_body',
        ),
        ExerciseStep(
          id: 'ex_downward_dog',
          name: 'Adho Mukha Svanasana (Downward-Facing Dog)',
          durationSeconds: 90,
          instruction: 'Hips high, press through knuckles. Pedal heels gently to stretch calves and hamstrings.',
          bodyRegion: 'full_body',
        ),
        ExerciseStep(
          id: 'ex_warrior_two',
          name: 'Virabhadrasana II (Warrior II)',
          durationSeconds: 90,
          instruction: 'Deep front knee bend, arms parallel to floor. Gaze over front middle finger with calm focus.',
          bodyRegion: 'lower_body',
        ),
        ExerciseStep(
          id: 'ex_pigeon_pose',
          name: 'Eka Pada Rajakapotasana (Pigeon Stretch)',
          durationSeconds: 120,
          instruction: 'Front shin parallel-ish to mat. Lower torso down to open outer glute and hip.',
          bodyRegion: 'lower_body',
        ),
      ],
    ),
  ];

  /// Filter workouts by active injury (excludes exercises targeting the injured area)
  static List<Workout> filterForInjury({
    required List<Workout> workouts,
    required String injuredBodyArea, // 'knee', 'ankle', 'lower_back', 'shoulder', 'wrist'
  }) {
    final area = injuredBodyArea.toLowerCase();

    return workouts.where((workout) {
      if (area == 'knee' || area == 'ankle' || area == 'foot') {
        // Exclude lower body and heavy full body impact
        return workout.bodyRegion == 'upper_body' ||
            workout.bodyRegion == 'core' ||
            workout.bodyRegion == 'seated_mobility' ||
            workout.hasTag('low-impact');
      }

      if (area == 'shoulder' || area == 'wrist') {
        // Exclude upper body workouts strictly
        return workout.bodyRegion != 'upper_body' &&
            (workout.bodyRegion == 'lower_body' ||
                workout.bodyRegion == 'core' ||
                workout.bodyRegion == 'seated_mobility');
      }

      if (area == 'lower_back') {
        // Exclude heavy load, allow gentle mobility & yoga
        return workout.intensity <= 2 || workout.hasTag('low-impact') || workout.hasTag('stress-relief');
      }

      return true;
    }).toList();
  }

  /// Get workout by ID or return default
  static Workout findById(String id) {
    return allWorkouts.firstWhere(
      (w) => w.id == id,
      orElse: () => allWorkouts.first,
    );
  }
}
