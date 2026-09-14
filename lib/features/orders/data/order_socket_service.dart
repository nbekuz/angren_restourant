import 'dart:async';

import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Realtime order alerts are handled by polling `/partner/orders`.
/// This stub keeps the import graph stable without demo timers.
final orderSocketServiceProvider = Provider<OrderSocketService>((ref) {
  final service = OrderSocketService();
  ref.onDispose(service.dispose);
  return service;
});

class OrderSocketService {
  final StreamController<PartnerOrder> _controller =
      StreamController<PartnerOrder>.broadcast();

  Stream<PartnerOrder> get incomingOrders => _controller.stream;
  bool get isRunning => false;

  void start({Duration interval = const Duration(seconds: 18)}) {}

  void stop() {}

  void dispose() {
    _controller.close();
  }
}
