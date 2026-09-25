import 'package:eda_restaurant/features/menu/data/menu_api_repository.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  return ScheduleNotifier(ref);
});

class ScheduleState {
  const ScheduleState({
    required this.weeklySchedule,
    required this.temporaryClosed,
    this.loading = false,
    this.saving = false,
  });

  final List<DaySchedule> weeklySchedule;
  final bool temporaryClosed;
  final bool loading;
  final bool saving;

  ScheduleState copyWith({
    List<DaySchedule>? weeklySchedule,
    bool? temporaryClosed,
    bool? loading,
    bool? saving,
  }) {
    return ScheduleState(
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      temporaryClosed: temporaryClosed ?? this.temporaryClosed,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier(this._ref)
      : super(
          ScheduleState(
            weeklySchedule: [
              for (var weekday = 1; weekday <= 7; weekday++)
                DaySchedule(
                  weekday: weekday,
                  openTime: weekday >= 6 ? '12:00' : '11:00',
                  closeTime: '20:00',
                  isClosed: false,
                ),
            ],
            temporaryClosed: false,
            loading: true,
          ),
        ) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repo = _ref.read(menuApiRepositoryProvider);
    final days = await repo.fetchSchedule();
    final profile = await repo.fetchMerchantProfile();
    final isOpen = profile?.isOpen ?? true;
    state = state.copyWith(
      weeklySchedule: days,
      temporaryClosed: !isOpen,
      loading: false,
    );
    await persistRestaurantStatus(
      _ref,
      isOpen ? RestaurantStatus.open : RestaurantStatus.closed,
    );
  }

  Future<void> refresh() => _load();

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

  Future<bool> save() async {
    state = state.copyWith(saving: true);
    final result = await _ref.read(menuApiRepositoryProvider).saveSchedule(
          days: state.weeklySchedule,
          isOpen: !state.temporaryClosed,
        );
    state = state.copyWith(saving: false);
    if (result == null) return false;
    state = state.copyWith(
      weeklySchedule: result.days,
      temporaryClosed: !result.isOpen,
    );
    await persistRestaurantStatus(
      _ref,
      result.isOpen ? RestaurantStatus.open : RestaurantStatus.closed,
    );
    _ref.invalidate(merchantProfileProvider);
    return true;
  }
}
