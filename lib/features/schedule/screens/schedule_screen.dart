import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/mindset_wisdom.dart';
import '../../../core/models/calendar_event.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mindset_background.dart';
import '../../../core/widgets/mindset_reset_modal.dart';
import '../schedule_controller.dart';

/// Interactive Schedule Sync Screen with Google Calendar sync, keyword load indicators & 1-tap overrides
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  void _showAddEventDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('📅 Add Calendar Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type any event title. Life-load keywords (e.g. exam, quiz, submission, lab, meeting) will auto-adjust daily fitness targets.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Algorithms Final Exam, Project Viva',
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final text = titleController.text.trim();
              if (text.isNotEmpty) {
                final now = DateTime.now();
                ref.read(scheduleControllerProvider.notifier).addCalendarEvent(
                  title: text,
                  startTime: now.add(const Duration(hours: 1)),
                  endTime: now.add(const Duration(hours: 3)),
                );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Added "$text" to calendar. Targets auto-calibrated!'),
                    backgroundColor: AppColors.deepTeal,
                  ),
                );
              }
            },
            child: const Text('Add Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleControllerProvider);
    final controller = ref.read(scheduleControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final days = List.generate(7, (i) => now.add(Duration(days: i - now.weekday + 1)));
    final selectedDayLoad = schedule.getEffectiveLoadForDate(schedule.selectedDate);

    // Filter events for selected date
    final selectedEvents = schedule.events.where((e) {
      return e.startTime.year == schedule.selectedDate.year &&
          e.startTime.month == schedule.selectedDate.month &&
          e.startTime.day == schedule.selectedDate.day;
    }).toList();

    return MindsetBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Schedule & Life Load'),
          actions: [
            IconButton(
              tooltip: 'Mindset Theme',
              icon: const Icon(Icons.palette_outlined),
              onPressed: () => MindsetBackground.showThemePicker(context),
            ),
            IconButton(
              tooltip: 'Sync Google Calendar',
              icon: schedule.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepTeal),
                    )
                  : const Icon(Icons.sync_rounded),
              onPressed: schedule.isSyncing
                  ? null
                  : () async {
                      await controller.syncGoogleCalendar();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📅 Google Calendar synced successfully! Keywords refreshed.'),
                            backgroundColor: AppColors.deepTeal,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
            ),
            IconButton(
              tooltip: '1-Min Mindset Reset',
              icon: const Text('🧘', style: TextStyle(fontSize: 20)),
              onPressed: () => MindsetResetModal.show(context),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(context, ref),
        backgroundColor: AppColors.deepTeal,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Google Calendar Connection Status Card (Preserves Exact Test Requirement)
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withValues(alpha: 0.2),
                              Colors.red.withValues(alpha: 0.1),
                              Colors.amber.withValues(alpha: 0.1),
                              Colors.green.withValues(alpha: 0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Google Calendar (Read-Only)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              schedule.isConnected
                                  ? 'Auto-detecting exams & deadlines • ${schedule.accountEmail}'
                                  : 'Disconnected (Manual overrides active)',
                              style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: schedule.isConnected,
                        onChanged: (_) => controller.toggleGoogleCalendar(),
                        activeColor: AppColors.deepTeal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_rounded, size: 14, color: AppColors.lightTextSecondary),
                          const SizedBox(width: 4),
                          Text(
                            schedule.lastSyncedAt != null
                                ? 'Last synced: ${DateFormat('h:mm a').format(schedule.lastSyncedAt!)}'
                                : 'Synced just now',
                            style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: schedule.isSyncing
                            ? null
                            : () async {
                                await controller.syncGoogleCalendar();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('📅 Google Calendar synced! Targets recalculated.'),
                                      backgroundColor: AppColors.deepTeal,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                        icon: schedule.isSyncing
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                        label: Text(
                          schedule.isSyncing ? 'Syncing...' : 'Sync Calendar',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Interactive Week Strip
            const Text('Week-Ahead Load Forecast', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final isSelected = day.day == schedule.selectedDate.day && day.month == schedule.selectedDate.month;
                final isToday = day.day == now.day && day.month == now.month;
                final load = schedule.getEffectiveLoadForDate(day);

                Color dotColor = AppColors.loadLight;
                if (load == EventLoadLevel.exam) {
                  dotColor = AppColors.loadExam;
                } else if (load == EventLoadLevel.heavy) {
                  dotColor = AppColors.loadHeavy;
                } else if (load == EventLoadLevel.medium) {
                  dotColor = AppColors.loadMedium;
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectDate(day),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppColors.deepTeal.withValues(alpha: 0.22),
                                  AppColors.mintAccent.withValues(alpha: 0.12),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        color: !isSelected
                            ? (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02))
                            : null,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppColors.deepTeal : Colors.transparent,
                          width: 2.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.deepTeal.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(day)[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected ? AppColors.deepTeal : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: dotColor.withValues(alpha: 0.6),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 3. 1-Tap Manual Override Bar
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Load for ${DateFormat('EEE, MMM d').format(schedule.selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLoadColor(selectedDayLoad).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${selectedDayLoad.emoji} ${selectedDayLoad.label}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _getLoadColor(selectedDayLoad),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Override Day Load (1-Tap):', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Text('🎓'),
                        label: const Text('Exam Day'),
                        onPressed: () => controller.setDayOverride(schedule.selectedDate, EventLoadLevel.exam),
                      ),
                      ActionChip(
                        avatar: const Text('📅'),
                        label: const Text('Heavy Day'),
                        onPressed: () => controller.setDayOverride(schedule.selectedDate, EventLoadLevel.heavy),
                      ),
                      ActionChip(
                        avatar: const Text('✨'),
                        label: const Text('Free Day'),
                        onPressed: () => controller.setDayOverride(schedule.selectedDate, EventLoadLevel.light),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset Auto'),
                        onPressed: () => controller.clearDayOverride(schedule.selectedDate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Mindset & Cognitive Load Card (Mindset Enhancement)
            _buildCognitiveMindsetCard(context, selectedDayLoad, isDark),
            const SizedBox(height: 20),

            // 4. Detected Calendar Events for Selected Day
            Text(
              'Events for ${DateFormat('MMM d').format(schedule.selectedDate)} (${selectedEvents.length})',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),

            if (selectedEvents.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text('✨', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 8),
                    Text('No heavy events scheduled', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('Open schedule provides full headroom for your routine.', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                  ],
                ),
              )
            else
              ...selectedEvents.map((e) {
                final color = _getLoadColor(e.loadLevel);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    border: BorderSide(color: color.withValues(alpha: 0.3)),
                    child: Row(
                      children: [
                        Text(e.loadLevel.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('h:mm a').format(e.startTime)} - ${DateFormat('h:mm a').format(e.endTime)} • ${e.loadLevel.label}',
                                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 60),
          ],
        ),
      ),
    ),
  );
}

  Color _getLoadColor(EventLoadLevel level) {
    switch (level) {
      case EventLoadLevel.light:
        return AppColors.loadLight;
      case EventLoadLevel.medium:
        return AppColors.loadMedium;
      case EventLoadLevel.heavy:
        return AppColors.loadHeavy;
      case EventLoadLevel.exam:
        return AppColors.loadExam;
    }
  }

  Widget _buildCognitiveMindsetCard(BuildContext context, EventLoadLevel load, bool isDark) {
    String mindsetAdvice = 'Your schedule has ample headroom. Enjoy your movement without rush.';
    String mindsetTitle = 'Optimal Movement Window';
    String emoji = '🌱';

    if (load == EventLoadLevel.exam) {
      mindsetTitle = 'Cognitive Energy Protection';
      emoji = '🎓';
      mindsetAdvice = 'Your brain consumes 20% of resting glucose. Downscaling physical load today preserves mental sharpness for your exams. It is smart biology, not quitting.';
    } else if (load == EventLoadLevel.heavy) {
      mindsetTitle = 'Stress-Load Balancing';
      emoji = '⚖️';
      mindsetAdvice = 'Deadlines create sympathetic nervous arousal. A gentle routine flushes cortisol without adding muscular fatigue.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF2F7F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mindsetTitle,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.deepTeal),
                    ),
                    GestureDetector(
                      onTap: () => MindsetResetModal.show(context),
                      child: const Text('🧘 Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepTeal)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mindsetAdvice,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
