import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MindsetTheme {
  zen(
    id: 'zen',
    name: 'Zen Forest',
    emoji: '🌿',
    mindsetIntent: 'Lowers cortisol, grounds the nervous system & clears mental clutter',
    darkBaseColor: Color(0xFF091214),
    darkOrb1: Color(0xFF0F4C5C),
    darkOrb2: Color(0xFF2EC4B6),
    darkOrb3: Color(0xFF092E33),
    lightBaseColor: Color(0xFFF4F8F7),
    lightOrb1: Color(0xFFD8EFEA),
    lightOrb2: Color(0xFFE2F4F0),
    lightOrb3: Color(0xFFC7E6DE),
  ),
  dawn(
    id: 'dawn',
    name: 'Dawn Horizon',
    emoji: '🌅',
    mindsetIntent: 'Awakens morning energy, optimism, and unshakeable momentum',
    darkBaseColor: Color(0xFF130E14),
    darkOrb1: Color(0xFF7A3042),
    darkOrb2: Color(0xFFE07A5F),
    darkOrb3: Color(0xFF3B182A),
    lightBaseColor: Color(0xFFFDF6F4),
    lightOrb1: Color(0xFFFFE4DC),
    lightOrb2: Color(0xFFFDE2EC),
    lightOrb3: Color(0xFFFFD7CC),
  ),
  cosmic(
    id: 'cosmic',
    name: 'Deep Focus',
    emoji: '🌌',
    mindsetIntent: 'Silences overthinking, eases exam anxiety & sharpens cognitive concentration',
    darkBaseColor: Color(0xFF090D1A),
    darkOrb1: Color(0xFF1E2856),
    darkOrb2: Color(0xFF4C35A8),
    darkOrb3: Color(0xFF101838),
    lightBaseColor: Color(0xFFF2F4FB),
    lightOrb1: Color(0xFFDFE4FA),
    lightOrb2: Color(0xFFEAE7FC),
    lightOrb3: Color(0xFFCCD5F7),
  ),
  ocean(
    id: 'ocean',
    name: 'Ocean Flow',
    emoji: '🌊',
    mindsetIntent: 'Fluid rhythmic movement, deep diaphragmatic breathing & stress release',
    darkBaseColor: Color(0xFF07121D),
    darkOrb1: Color(0xFF0C385C),
    darkOrb2: Color(0xFF007791),
    darkOrb3: Color(0xFF08243A),
    lightBaseColor: Color(0xFFF0F6FA),
    lightOrb1: Color(0xFFD4EBF7),
    lightOrb2: Color(0xFFE0F2FE),
    lightOrb3: Color(0xFFC2E2F5),
  ),
  aura(
    id: 'aura',
    name: 'Self-Compassion',
    emoji: '🌸',
    mindsetIntent: 'Healing self-compassion, dissolves body shame & honors cyclic recovery',
    darkBaseColor: Color(0xFF140D17),
    darkOrb1: Color(0xFF562361),
    darkOrb2: Color(0xFF913C87),
    darkOrb3: Color(0xFF38153E),
    lightBaseColor: Color(0xFFFAF3F9),
    lightOrb1: Color(0xFFF6DFEF),
    lightOrb2: Color(0xFFFDE8F7),
    lightOrb3: Color(0xFFEFC6E5),
  );

  final String id;
  final String name;
  final String emoji;
  final String mindsetIntent;
  final Color darkBaseColor;
  final Color darkOrb1;
  final Color darkOrb2;
  final Color darkOrb3;
  final Color lightBaseColor;
  final Color lightOrb1;
  final Color lightOrb2;
  final Color lightOrb3;

  const MindsetTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.mindsetIntent,
    required this.darkBaseColor,
    required this.darkOrb1,
    required this.darkOrb2,
    required this.darkOrb3,
    required this.lightBaseColor,
    required this.lightOrb1,
    required this.lightOrb2,
    required this.lightOrb3,
  });
}

class MindsetThemeController extends StateNotifier<MindsetTheme> {
  MindsetThemeController() : super(MindsetTheme.zen) {
    _loadTheme();
  }

  static const _storageKey = 'fitsync_mindset_theme';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_storageKey);
      if (savedId != null) {
        state = MindsetTheme.values.firstWhere(
          (t) => t.id == savedId,
          orElse: () => MindsetTheme.zen,
        );
      }
    } catch (_) {}
  }

  Future<void> setTheme(MindsetTheme theme) async {
    state = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, theme.id);
    } catch (_) {}
  }
}

final mindsetThemeControllerProvider =
    StateNotifierProvider<MindsetThemeController, MindsetTheme>((ref) {
  return MindsetThemeController();
});

