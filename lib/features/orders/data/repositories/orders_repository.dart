import 'package:dio/dio.dart';
import 'package:eda_restaurant/core/network/api_client.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.watch(apiClientProvider));
});

class OrdersRepository {
  const OrdersRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PartnerOrder>> fetchOrders() async {
    try {
      final response = await _apiClient.get<List<dynamic>>('/partner/orders');
      final rows = response.data ?? [];
      if (rows.isEmpty) return [];
      return rows.map((raw) => _mapOrder(raw as Map<String, dynamic>)).toList();
    } on DioException {
      return [];
    }
  }

  Future<PartnerOrder> accept(String orderId) async {
    return updateStatus(orderId, PartnerOrderStatus.preparing);
  }

  Future<PartnerOrder> reject(String orderId) async {
    return updateStatus(orderId, PartnerOrderStatus.cancelled);
  }

  Future<PartnerOrder> updateStatus(
    String orderId,
    PartnerOrderStatus status,
  ) async {
    final apiStatus = _toApiStatus(status);
    try {
      await _apiClient.patch<Map<String, dynamic>>(
        '/partner/orders/$orderId/status',
        data: {'status': apiStatus},
      );
    } on DioException {
      throw Exception('Failed to update order');
    }
    return _mapOrder({
      'id': orderId,
      'orderNumber': orderId,
      'status': apiStatus,
    }).copyWith(status: status);
  }

  PartnerOrder _mapOrder(Map<String, dynamic> json) {
    final status = _fromApiStatus(json['status'] as String?);
    return PartnerOrder(
      id: json['id'] as String,
      number: json['orderNumber'] as String? ?? json['id'] as String,
      customerName: 'Customer',
      customerPhone: '',
      address: '',
      items: const [],
      total: double.tryParse('${json['total']}') ?? 0,
      status: status,
      paymentMethod: PaymentMethod.cash,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      etaMinutes: json['etaMinutes'] as int? ?? 20,
      allowReject: status == PartnerOrderStatus.incoming,
    );
  }

  PartnerOrderStatus _fromApiStatus(String? status) {
    switch (status) {
      case 'created':
        return PartnerOrderStatus.incoming;
      case 'accepted':
      case 'preparing':
        return PartnerOrderStatus.preparing;
      case 'ready':
        return PartnerOrderStatus.ready;
      case 'delivered':
        return PartnerOrderStatus.completed;
      case 'cancelled':
        return PartnerOrderStatus.cancelled;
      default:
        return PartnerOrderStatus.incoming;
    }
  }

  String _toApiStatus(PartnerOrderStatus status) {
    switch (status) {
      case PartnerOrderStatus.incoming:
        return 'accepted';
      case PartnerOrderStatus.preparing:
        return 'preparing';
      case PartnerOrderStatus.ready:
        return 'ready';
      case PartnerOrderStatus.completed:
        return 'delivered';
      case PartnerOrderStatus.cancelled:
        return 'cancelled';
    }
  }
}
