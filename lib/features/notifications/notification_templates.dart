import '../../core/models/notification_settings.dart';

/// Non-guilt, life-aware notification template repository
/// Supports English and Tanglish / Tamil-friendly AI coach messages (Pages 3 & 4)
class NotificationTemplates {
  static final Map<String, Map<NotificationTone, List<String>>> _templates = {
    'exam_day': {
      NotificationTone.friendly: [
        'Exam week is heavy. A 10-minute gentle stretch will clear your head and protect your streak.',
        'Hey, exam tension-la irukinga nu theriyum. Just taking a 10-minute stretch will clear your mind!',
        'Good luck with exams today! We dialed your target to light mode so you stay stress-free.',
      ],
      NotificationTone.calm: [
        'Your mind carries a deep load today. Rest and breathe; movement will wait whenever you are ready.',
        'Peace over pressure. Resting on an exam day honors your priorities and keeps your streak alive.',
      ],
      NotificationTone.playful: [
        'Brain cells burning bright today! Take a quick 10-min study break to crush that test.',
        'Exam shield activated 🛡️. Couch time or a micro-walk both count as a win today.',
      ],
    },
    'low_sleep': {
      NotificationTone.friendly: [
        'Nethu night late-ah padichu tired-ah irundha paravala, streak break aagadhu. Light walk pothum!',
        'Short sleep logged last night. We’ve dialed today’s target way down so you recharge with zero guilt.',
        'Running low on rest? Today is about gentle recovery, not crushing robot targets.',
      ],
      NotificationTone.calm: [
        'Honor your fatigue today. Rest is where healing and biological resilience are forged.',
        'Soft steps today. Let your nervous system settle with a gentle 15-minute breather.',
      ],
      NotificationTone.playful: [
        'Running on 20% battery? Coach put your target on power-saving mode. Rest easy!',
        'Yawn patrol! Low sleep means today is officially a gentle movement day.',
      ],
    },
    'high_stress': {
      NotificationTone.friendly: [
        'Tension feeling high? A 15-minute de-stress flow is waiting whenever you need a mental pause.',
        'Breathe deep. Today’s goal is clearing cortisol, not breaking sweat records.',
      ],
      NotificationTone.calm: [
        'Inhale deeply for 4 seconds, exhale for 4. Today is about taking care of your nervous system.',
        'You do not have to carry everything at once. Step away for 10 minutes of restorative flow.',
      ],
      NotificationTone.playful: [
        'Stress monster spotted! Time for a quick 10-min zen reset to kick it out.',
        'Shake off the tension like a golden retriever. A quick stretch works wonders!',
      ],
    },
    'cycle_menstrual': {
      NotificationTone.friendly: [
        'Periods apo rest edukuradhu weakness illa, smart recovery. Cramp-relief gentle yoga try pannunga 🌸.',
        'Period cramp guard active. Heavy lifting is off; gentle stretching and warm tea are your best friends today.',
      ],
      NotificationTone.calm: [
        'Honor your body’s natural rhythm. Rest is healing. We adjusted your targets to gentle restoration.',
      ],
      NotificationTone.playful: [
        'Period shield on! Cozy up with heating patches and light stretching—streak stays 100% safe.',
      ],
    },
    'anti_robot': {
      NotificationTone.friendly: [
        'Level 3 kashtam-ah irundhucha? Don\'t worry, robo maari force panna maatom. Namma steady-ah consolidate pannuvom!',
        'Anti-Robot Guard: You gave your best today. We will consolidate this level before unlocking the next.',
      ],
      NotificationTone.calm: [
        'True fitness is about patience and adaptation. Building a strong base beats rushing levels.',
      ],
      NotificationTone.playful: [
        'Robot coach defeated! Human recovery mode engaged. Tomorrow we lock down this level.',
      ],
    },
    'push_day': {
      NotificationTone.friendly: [
        'Peak readiness unlocked today! You have great energy reserves if you feel like a push day.',
        'You are glowing with energy today. Feel free to challenge yourself or keep it steady!',
      ],
      NotificationTone.calm: [
        'Your body is grounded, restored, and strong. Enjoy moving with full capacity today.',
        'Prime readiness today. Move with grace, power, and intention.',
      ],
      NotificationTone.playful: [
        'Rocket mode activated 🚀! Your readiness battery is at 100%—let’s conquer today.',
        'Look at those numbers! Today is a playground if you want to push your personal best.',
      ],
    },
    'rest_day': {
      NotificationTone.friendly: [
        'Intentional rest day logged. Rest on heavy days never breaks your flex streak.',
        'Recharge mode on. Recovery is half of the fitness equation.',
      ],
      NotificationTone.calm: [
        'Rest is active recovery. Recharge peacefully and breathe.',
        'Stillness is medicine. Thank your body for everything it carried this week.',
      ],
      NotificationTone.playful: [
        'Coach-approved couch mode! Resting like a champion keeps your streak 100% intact.',
        'Rest day unlocked. Put your feet up—you earned every second of it!',
      ],
    },
    'regular_morning': {
      NotificationTone.friendly: [
        'Good morning! Today’s target is calibrated for your steady pace. Have a great day!',
        'Consistency beats perfection. A 20-minute movement window is ready for you.',
      ],
      NotificationTone.calm: [
        'A peaceful morning to you. Let’s move with presence and balance today.',
        'One breath at a time, one step at a time. Honor your body’s rhythm today.',
      ],
      NotificationTone.playful: [
        'Rise and shine, athlete! Ready for today’s gentle mission?',
        'Another day, another flexible victory. Let’s get those adapted steps in!',
      ],
    },
  };

  /// Select best matching non-guilt message based on life context and preferred tone
  static String getMessage({
    required String context,
    required NotificationTone tone,
  }) {
    final contextMap = _templates[context] ?? _templates['regular_morning']!;
    final toneList = contextMap[tone] ?? contextMap[NotificationTone.friendly]!;
    return toneList.first;
  }
}
