import 'package:dio/dio.dart';
import 'package:eda_restaurant/core/network/api_client.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuApiRepositoryProvider = Provider<MenuApiRepository>((ref) {
  return MenuApiRepository(ref.watch(apiClientProvider));
});

final merchantProfileProvider = FutureProvider.autoDispose<MerchantProfile?>((ref) {
  return ref.watch(menuApiRepositoryProvider).fetchMerchantProfile();
});

class MenuApiRepository {
  MenuApiRepository(this._api);

  final ApiClient _api;

  Future<MerchantProfile?> fetchMerchantProfile() async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/partner/merchant');
      final data = response.data;
      if (data == null) return null;
      return MerchantProfile(
        id: data['id'] as String,
        name: data['name'] as String,
        type: data['type'] as String? ?? 'restaurant',
        address: data['address'] as String? ?? '',
        phone: '',
        logoUrl: data['logoUrl'] as String?,
        coverUrl: data['coverUrl'] as String?,
        isOpen: data['isOpen'] as bool? ?? true,
        workingHoursText: data['workingHoursText'] as String?,
      );
    } on DioException {
      return null;
    }
  }

  Future<List<MenuCategory>> fetchCategories() async {
    try {
      final response =
          await _api.get<List<dynamic>>('/partner/products/categories');
      return (response.data ?? []).map((raw) {
        final map = raw as Map<String, dynamic>;
        return MenuCategory(
          id: map['id'] as String,
          name: map['name'] as String,
          sortOrder: map['sortOrder'] as int? ?? 0,
          productCount: 0,
        );
      }).toList();
    } on DioException {
      return [];
    }
  }

  Future<List<MenuProduct>> fetchProducts() async {
    try {
      final response = await _api.get<List<dynamic>>('/partner/products');
      return (response.data ?? []).map((raw) {
        final map = raw as Map<String, dynamic>;
        return MenuProduct(
          id: map['id'] as String,
          categoryId: map['categoryId'] as String? ?? '',
          name: map['name'] as String,
          description: map['description'] as String? ?? '',
          price: double.tryParse('${map['price']}') ?? 0,
          imageUrl: map['imageUrl'] as String? ?? '',
          weightGrams: map['weightGrams'] as int? ?? 0,
          available: map['isAvailable'] as bool? ?? true,
          stock: 999,
          discountPercent: 0,
          ingredients: const [],
        );
      }).toList();
    } on DioException {
      return [];
    }
  }

  Future<MenuProduct?> saveProduct(MenuProduct product) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/partner/products',
        data: {
          if (product.id.isNotEmpty) 'id': product.id,
          'categoryId': product.categoryId.isEmpty ? null : product.categoryId,
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isAvailable': product.available,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return product.copyWith(id: data['id'] as String);
    } on DioException {
      return null;
    }
  }

  Future<MerchantProfile?> updateMerchant({
    String? name,
    String? description,
    bool? isOpen,
    String? workingHoursText,
    String? logoUrl,
    String? coverUrl,
  }) async {
    try {
      final response = await _api.patch<Map<String, dynamic>>(
        '/partner/merchant',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (isOpen != null) 'isOpen': isOpen,
          if (workingHoursText != null) 'workingHoursText': workingHoursText,
          if (logoUrl != null) 'logoUrl': logoUrl,
          if (coverUrl != null) 'coverUrl': coverUrl,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return MerchantProfile(
        id: data['id'] as String,
        name: data['name'] as String,
        type: data['type'] as String? ?? 'restaurant',
        address: data['address'] as String? ?? '',
        phone: '',
        logoUrl: data['logoUrl'] as String?,
        coverUrl: data['coverUrl'] as String?,
        isOpen: data['isOpen'] as bool? ?? true,
        workingHoursText: data['workingHoursText'] as String?,
      );
    } on DioException {
      return null;
    }
  }
}

class MerchantProfile {
  const MerchantProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    this.logoUrl,
    this.coverUrl,
    this.isOpen = true,
    this.workingHoursText,
  });

  final String id;
  final String name;
  final String type;
  final String address;
  final String phone;
  final String? logoUrl;
  final String? coverUrl;
  final bool isOpen;
  final String? workingHoursText;
}
