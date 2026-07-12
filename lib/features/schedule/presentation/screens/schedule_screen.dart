import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/schedule_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          120,
        ),
        children: [
          _StatusPanel(schedule: schedule, ref: ref),
          const SizedBox(height: AppSpacing.lg),
          for (final day in schedule.weeklySchedule)
            _DayCard(
              dayName: _dayNames[day.weekday - 1],
              day: day,
              onChanged: (updated) =>
                  ref.read(scheduleProvider.notifier).updateDay(updated),
            ),
        ].animate(interval: 35.ms).fadeIn().slideY(begin: 0.03),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.page),
        child: PrimaryButton(
          label: 'Save schedule',
          icon: Icons.save_rounded,
          onPressed: () async {
            await ref.read(scheduleProvider.notifier).save();
            if (!context.mounted) return;
            ToastScope.of(context).success('Schedule saved');
          },
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.schedule, required this.ref});

  final ScheduleState schedule;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.button,
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: schedule.temporaryClosed,
            activeThumbColor: Colors.white,
            title: const Text(
              'Temporary close',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Pause incoming orders until reopened',
              style: TextStyle(color: Colors.white70),
            ),
            onChanged: ref.read(scheduleProvider.notifier).setTemporaryClosed,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: schedule.holidayMode,
            activeThumbColor: Colors.white,
            title: const Text(
              'Holiday mode',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: const Text(
              'Show holiday hours to customers',
              style: TextStyle(color: Colors.white70),
            ),
            onChanged: ref.read(scheduleProvider.notifier).setHolidayMode,
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayName,
    required this.day,
    required this.onChanged,
  });

  final String dayName;
  final DaySchedule day;
  final ValueChanged<DaySchedule> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  day.isClosed
                      ? 'Closed'
                      : '${day.openTime} - ${day.closeTime}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: day.isClosed ? null : () => _pick(context, true),
            child: Text(day.openTime),
          ),
          TextButton(
            onPressed: day.isClosed ? null : () => _pick(context, false),
            child: Text(day.closeTime),
          ),
          Switch.adaptive(
            value: !day.isClosed,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => onChanged(day.copyWith(isClosed: !value)),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, bool open) async {
    final source = open ? day.openTime : day.closeTime;
    final parts = source.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 10,
        minute: int.tryParse(parts.last) ?? 0,
      ),
    );
    if (picked == null) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    onChanged(
      open ? day.copyWith(openTime: value) : day.copyWith(closeTime: value),
    );
  }
}
