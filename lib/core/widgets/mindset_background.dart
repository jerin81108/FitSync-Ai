import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../theme/mindset_theme_controller.dart';

/// Mindset Background wrapper providing ambient psychological aura gradients
/// behind frosted glass cards across all screens.
class MindsetBackground extends ConsumerWidget {
  final Widget child;

  const MindsetBackground({super.key, required this.child});

  static Future<void> showThemePicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _MindsetThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(mindsetThemeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? theme.darkBaseColor : theme.lightBaseColor;
    final orb1Color = isDark ? theme.darkOrb1.withValues(alpha: 0.38) : theme.lightOrb1.withValues(alpha: 0.70);
    final orb2Color = isDark ? theme.darkOrb2.withValues(alpha: 0.26) : theme.lightOrb2.withValues(alpha: 0.60);
    final orb3Color = isDark ? theme.darkOrb3.withValues(alpha: 0.32) : theme.lightOrb3.withValues(alpha: 0.65);

    return Scaffold(
      backgroundColor: baseColor,
      body: Stack(
        children: [
          // Ambient Aura Orb 1 (Top-Right)
          Positioned(
            top: -60,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      orb1Color,
                      orb1Color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ambient Aura Orb 2 (Mid-Left)
          Positioned(
            top: 240,
            left: -80,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      orb2Color,
                      orb2Color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ambient Aura Orb 3 (Bottom-Right)
          Positioned(
            bottom: 40,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      orb3Color,
                      orb3Color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Page Content
          child,
        ],
      ),
    );
  }
}

class _MindsetThemePickerSheet extends ConsumerWidget {
  const _MindsetThemePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(mindsetThemeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🎨', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mindset Background Themes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Ambient visual frequencies designed for mental states',
                        style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
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
          const SizedBox(height: 18),

          ...MindsetTheme.values.map((theme) {
            final isSelected = currentTheme == theme;
            final primaryOrb = isDark ? theme.darkOrb1 : theme.lightOrb1;
            final secondaryOrb = isDark ? theme.darkOrb2 : theme.lightOrb2;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                  width: isSelected ? 2 : 1,
                ),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          primaryOrb.withValues(alpha: 0.18),
                          secondaryOrb.withValues(alpha: 0.08),
                        ],
                      )
                    : null,
                color: !isSelected ? (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF9FAFB)) : null,
              ),
              child: ListTile(
                onTap: () {
                  ref.read(mindsetThemeControllerProvider.notifier).setTheme(theme);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✨ Mindset background changed to "${theme.name}"!'),
                      backgroundColor: AppColors.deepTeal,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryOrb, secondaryOrb],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryOrb.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(theme.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppColors.deepTeal : null,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.deepTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.deepTeal),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  theme.mindsetIntent,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                trailing: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white30 : Colors.black26),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

