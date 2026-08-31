import 'dart:async';

import 'package:eda_restaurant/core/services/order_alert_service.dart';
import 'package:eda_restaurant/features/orders/data/repositories/orders_repository.dart';
import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<PartnerOrder>>((ref) {
      return OrdersNotifier(ref);
    });

final incomingOrderProvider = StateProvider<PartnerOrder?>((ref) => null);

final orderByIdProvider = Provider.family<PartnerOrder?, String>((ref, id) {
  final orders = ref.watch(ordersProvider);
  for (final order in orders) {
    if (order.id == id) return order;
  }
  return null;
});

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final orders = ref.watch(ordersProvider);
  final completed = orders
      .where((order) => order.status == PartnerOrderStatus.completed)
      .toList();
  final revenue = completed.fold<double>(0, (sum, order) => sum + order.total);
  final incoming = orders
      .where((order) => order.status == PartnerOrderStatus.incoming)
      .length;
  final preparing = orders
      .where((order) => order.status == PartnerOrderStatus.preparing)
      .length;

  return DemoData.stats.copyWith(
    todayOrders: orders.length,
    todayRevenue: revenue == 0 ? DemoData.stats.todayRevenue : revenue,
    pending: incoming,
    preparing: preparing,
    completed: completed.length,
    avgCheck: completed.isEmpty
        ? DemoData.stats.avgCheck
        : revenue / completed.length,
  );
});

class OrdersNotifier extends StateNotifier<List<PartnerOrder>> {
  OrdersNotifier(this._ref) : super(const []) {
    unawaited(refresh());
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _poll());
  }

  final Ref _ref;
  Timer? _pollTimer;
  final Set<String> _knownIncomingIds = {};

  Future<void> _poll() async {
    final previous = state;
    await refresh();
    for (final order in state) {
      if (order.status != PartnerOrderStatus.incoming) continue;
      if (_knownIncomingIds.add(order.id)) {
        _receiveIncomingOrder(order);
      }
    }
    for (final order in previous) {
      _knownIncomingIds.add(order.id);
    }
  }

  Future<void> refresh() async {
    state = await _ref.read(ordersRepositoryProvider).fetchOrders();
  }

  Future<void> accept(String orderId) async {
    final updated = await _ref.read(ordersRepositoryProvider).accept(orderId);
    _upsert(updated);
    _clearIncoming(orderId);
    await OrderAlertService.stopIncomingAlert();
  }

  Future<void> reject(String orderId) async {
    final updated = await _ref.read(ordersRepositoryProvider).reject(orderId);
    _upsert(updated);
    _clearIncoming(orderId);
    await OrderAlertService.stopIncomingAlert();
  }

  Future<void> setStatus(String orderId, PartnerOrderStatus status) async {
    final current = _find(orderId);
    if (current == null) return;
    final updated = current.copyWith(
      status: status,
      allowReject: status == PartnerOrderStatus.incoming,
      etaMinutes:
          status == PartnerOrderStatus.completed ||
              status == PartnerOrderStatus.cancelled
          ? 0
          : current.etaMinutes,
    );
    _upsert(updated);
    await _ref.read(ordersRepositoryProvider).updateStatus(orderId, status);
  }

  void simulateIncoming() {
    final incoming = state
        .where((order) => order.status == PartnerOrderStatus.incoming)
        .firstOrNull;
    if (incoming != null) {
      _receiveIncomingOrder(incoming);
    }
  }

  void setSimulationEnabled(bool enabled) {
    if (enabled) {
      _pollTimer ??= Timer.periodic(const Duration(seconds: 15), (_) => _poll());
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  void dismissIncoming() {
    _ref.read(incomingOrderProvider.notifier).state = null;
    OrderAlertService.stopIncomingAlert();
  }

  PartnerOrder? _find(String orderId) {
    for (final order in state) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  void _receiveIncomingOrder(PartnerOrder order) {
    if (_find(order.id) == null) {
      state = [order, ...state];
    }
    _ref.read(incomingOrderProvider.notifier).state = order;
    OrderAlertService.startIncomingAlert();
  }

  void _upsert(PartnerOrder order) {
    final index = state.indexWhere((item) => item.id == order.id);
    if (index == -1) {
      state = [order, ...state];
      return;
    }
    state = [
      for (var i = 0; i < state.length; i++) i == index ? order : state[i],
    ];
  }

  void _clearIncoming(String orderId) {
    final incoming = _ref.read(incomingOrderProvider);
    if (incoming?.id == orderId) {
      _ref.read(incomingOrderProvider.notifier).state = null;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
