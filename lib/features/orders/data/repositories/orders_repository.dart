import 'package:dio/dio.dart';
import 'package:eda_restaurant/core/network/api_client.dart';
import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.watch(apiClientProvider));
});

class OrdersRepository {
  const OrdersRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PartnerOrder>> fetchOrders() async {
    await _simulateLatency();
    return List<PartnerOrder>.of(DemoData.orders);
  }

  Future<PartnerOrder> accept(String orderId) async {
    await _postStatus(orderId, PartnerOrderStatus.preparing);
    return _demoOrder(
      orderId,
    ).copyWith(status: PartnerOrderStatus.preparing, allowReject: false);
  }

  Future<PartnerOrder> reject(String orderId) async {
    await _postStatus(orderId, PartnerOrderStatus.cancelled);
    return _demoOrder(orderId).copyWith(
      status: PartnerOrderStatus.cancelled,
      allowReject: false,
      etaMinutes: 0,
    );
  }

  Future<PartnerOrder> updateStatus(
    String orderId,
    PartnerOrderStatus status,
  ) async {
    await _postStatus(orderId, status);
    return _demoOrder(orderId).copyWith(status: status);
  }

  Future<void> _postStatus(String orderId, PartnerOrderStatus status) async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/partner/orders/$orderId/status',
        data: {'status': status.name},
      );
    } on DioException {
      // The production client is wired through Dio; demo mode remains offline.
      await _simulateLatency();
    }
  }

  PartnerOrder _demoOrder(String orderId) {
    return DemoData.orders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => DemoData.orders.first,
    );
  }

  Future<void> _simulateLatency() {
    return Future<void>.delayed(const Duration(milliseconds: 220));
  }
}
