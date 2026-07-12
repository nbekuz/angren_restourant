import 'dart:async';

import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderSocketServiceProvider = Provider<OrderSocketService>((ref) {
  final service = OrderSocketService();
  ref.onDispose(service.dispose);
  return service;
});

class OrderSocketService {
  final StreamController<PartnerOrder> _controller =
      StreamController<PartnerOrder>.broadcast();
  Timer? _timer;
  int _counter = 20000;

  Stream<PartnerOrder> get incomingOrders => _controller.stream;
  bool get isRunning => _timer?.isActive ?? false;

  void start({Duration interval = const Duration(seconds: 18)}) {
    if (isRunning) return;
    _timer = Timer.periodic(interval, (_) => emitIncomingOrder());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  PartnerOrder emitIncomingOrder() {
    final source = DemoData.orders[_counter % DemoData.orders.length];
    final order = source.copyWith(
      id: 'ord_${_counter + 1}',
      number: '${_counter + 1}',
      status: PartnerOrderStatus.incoming,
      createdAt: DateTime.now(),
      allowReject: true,
      etaMinutes: 20 + (_counter % 12),
      notes: _counter.isEven ? 'Demo socket order' : source.notes,
    );
    _counter++;
    _controller.add(order);
    return order;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
