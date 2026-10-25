import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/calendar_event.dart';
import '../../../core/widgets/glass_card.dart';
import '../schedule_controller.dart';

/// Interactive Schedule Sync Screen with keyword load indicators & 1-tap overrides
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Schedule & Life Load'),
        actions: [
          IconButton(
            tooltip: 'Sync Now',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar synced successfully. Keywords refreshed.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Google Calendar Connection Status Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.deepTeal.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_month, color: AppColors.deepTeal, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Google Calendar (Read-Only)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(
                          schedule.isConnected ? 'Auto-detecting exams & deadlines' : 'Disconnected (Manual overrides active)',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: schedule.isConnected,
                    onChanged: (_) => controller.toggleGoogleCalendar(),
                    activeThumbColor: AppColors.deepTeal,
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.deepTeal.withValues(alpha: 0.15)
                            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.deepTeal : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(day)[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.deepTeal : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
            const SizedBox(height: 24),

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
            const SizedBox(height: 32),
          ],
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
}
