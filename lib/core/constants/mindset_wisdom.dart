/// Curated mindset affirmations, cognitive reframing wisdom, and psychological anchors
class MindsetWisdom {
  static const List<({String title, String quote, String category, String emoji})> dailyMindsetAnchors = [
    (
      title: 'Consistency > Intensity',
      quote: 'You do not have to conquer the world in every session. A gentle 15-minute movement today rewires your brain for lifelong momentum.',
      category: 'Momentum',
      emoji: '🌱',
    ),
    (
      title: 'Rest Is Productive',
      quote: 'Muscles grow, neurons consolidate learning, and cortisol drops during rest—not during exertion. Rest is your tactical weapon.',
      category: 'Recovery',
      emoji: '🛡️',
    ),
    (
      title: 'Brain-Body Harmony',
      quote: 'On heavy academic or work days, your brain consumes 20% of your total energy. Downscaling physical load is intelligent biology.',
      category: 'Compassion',
      emoji: '🧠',
    ),
    (
      title: 'Leave Ego at the Door',
      quote: 'Your fitness is between you and your future self. No comparison, no robotic metrics—just authentic presence today.',
      category: 'Clarity',
      emoji: '🧘',
    ),
    (
      title: 'Small Wins Compound',
      quote: 'Even 5 deep breaths and a quick spinal stretch signals to your nervous system that you care. That is enough for today.',
      category: 'Resilience',
      emoji: '✨',
    ),
  ];

  static const List<({String intention, String emoji, String description})> workoutIntentions = [
    (
      intention: 'Mental Clarity',
      emoji: '🧠',
      description: 'Clear brain fog, improve cognitive blood flow, and reset focus.',
    ),
    (
      intention: 'Stress Release',
      emoji: '🍃',
      description: 'Exhale accumulated anxiety, open tight shoulders, and restore inner calm.',
    ),
    (
      intention: 'Recharge Energy',
      emoji: '⚡',
      description: 'Light, invigorating movement to awaken the nervous system without fatigue.',
    ),
    (
      intention: 'Pure Joy & Flow',
      emoji: '✨',
      description: 'Move freely without tracking numbers. Celebrate what your body can do today.',
    ),
  ];

  static const List<({String title, String milestone, String emoji, String mindsetLesson})> mentalResilienceMilestones = [
    (
      title: 'No-Guilt Champion',
      milestone: 'Logged Intentional Rest',
      emoji: '🛡️',
      mindsetLesson: 'Understood that skipping an intense workout on an exam day protects both grades and health.',
    ),
    (
      title: 'Anti-Robot Awareness',
      milestone: 'Acknowledged Fatigue Honestly',
      emoji: '🤖',
      mindsetLesson: 'Chose consolidation over blind progression. That is elite athletic self-awareness.',
    ),
    (
      title: 'Stress-Proof Adaptability',
      milestone: 'Scaled Down Under Life Load',
      emoji: '🌊',
      mindsetLesson: 'Bended like a reed in the wind instead of breaking against rigid expectations.',
    ),
    (
      title: 'Mind Over Ego',
      milestone: 'Prioritized Recovery Form',
      emoji: '🧘',
      mindsetLesson: 'Selected mobility & breathwork when ego demanded heavy strain.',
    ),
  ];

  static ({String title, String quote, String category, String emoji}) getTodaysAnchor() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return dailyMindsetAnchors[dayOfYear % dailyMindsetAnchors.length];
  }
}

