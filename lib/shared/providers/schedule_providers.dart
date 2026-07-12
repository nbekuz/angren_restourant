import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) {
    return ScheduleNotifier();
  },
);

class ScheduleState {
  const ScheduleState({
    required this.weeklySchedule,
    required this.temporaryClosed,
    required this.holidayMode,
  });

  final List<DaySchedule> weeklySchedule;
  final bool temporaryClosed;
  final bool holidayMode;

  ScheduleState copyWith({
    List<DaySchedule>? weeklySchedule,
    bool? temporaryClosed,
    bool? holidayMode,
  }) {
    return ScheduleState(
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      temporaryClosed: temporaryClosed ?? this.temporaryClosed,
      holidayMode: holidayMode ?? this.holidayMode,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier()
    : super(
        const ScheduleState(
          weeklySchedule: DemoData.weeklySchedule,
          temporaryClosed: false,
          holidayMode: false,
        ),
      );

  void updateDay(DaySchedule day) {
    state = state.copyWith(
      weeklySchedule: [
        for (final item in state.weeklySchedule)
          if (item.weekday == day.weekday) day else item,
      ],
    );
  }

  void setTemporaryClosed(bool value) {
    state = state.copyWith(temporaryClosed: value);
  }

  void setHolidayMode(bool value) {
    state = state.copyWith(holidayMode: value);
  }

  Future<void> save() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }
}
