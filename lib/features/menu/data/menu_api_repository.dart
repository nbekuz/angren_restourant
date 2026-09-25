import 'package:dio/dio.dart';
import 'package:eda_restaurant/core/i18n/localized_fields.dart';
import 'package:eda_restaurant/core/network/api_client.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuApiRepositoryProvider = Provider<MenuApiRepository>((ref) {
  final locale = ref.watch(localeProvider).languageCode;
  return MenuApiRepository(ref.watch(apiClientProvider), locale: locale);
});

final merchantProfileProvider =
    FutureProvider.autoDispose<MerchantProfile?>((ref) {
  return ref.watch(menuApiRepositoryProvider).fetchMerchantProfile();
});

class CatalogIngredient {
  const CatalogIngredient({
    required this.id,
    required this.name,
    this.nameRu,
    this.nameEn,
    this.merchantId,
  });

  final String id;
  final String name;
  final String? nameRu;
  final String? nameEn;
  final String? merchantId;

  bool get isOwned => merchantId != null && merchantId!.isNotEmpty;

  String label(String locale) => localizedField(
        locale,
        uz: name,
        ru: nameRu,
        en: nameEn,
        fallback: name,
      );

  CatalogIngredient copyWith({
    String? id,
    String? name,
    String? nameRu,
    String? nameEn,
    String? merchantId,
  }) {
    return CatalogIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      nameEn: nameEn ?? this.nameEn,
      merchantId: merchantId ?? this.merchantId,
    );
  }
}

class MenuApiRepository {
  MenuApiRepository(this._api, {required this.locale});

  final ApiClient _api;
  final String locale;

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  MenuProduct _mapProduct(Map<String, dynamic> map) {
    return MenuProduct(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameRu: map['nameRu'] as String?,
      nameEn: map['nameEn'] as String?,
      description: map['description'] as String? ?? '',
      descriptionRu: map['descriptionRu'] as String?,
      descriptionEn: map['descriptionEn'] as String?,
      price: double.tryParse('${map['price']}') ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      weightGrams: map['weightGrams'] as int? ?? 0,
      available: map['isAvailable'] as bool? ?? true,
      stock: 999,
      discountPercent: 0,
      ingredients: _stringList(map['ingredients']),
      ingredientsRu: _stringList(map['ingredientsRu']),
      ingredientsEn: _stringList(map['ingredientsEn']),
      ingredientIds: _stringList(map['ingredientIds']),
    );
  }

  Future<MerchantProfile?> fetchMerchantProfile() async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/partner/merchant');
      final data = response.data;
      if (data == null) return null;
      return MerchantProfile(
        id: data['id'] as String,
        name: localizedField(
          locale,
          uz: data['name'] as String?,
          ru: data['nameRu'] as String?,
          en: data['nameEn'] as String?,
          fallback: 'Merchant',
        ),
        nameUz: data['name'] as String? ?? '',
        nameRu: data['nameRu'] as String?,
        nameEn: data['nameEn'] as String?,
        description: data['description'] as String?,
        descriptionRu: data['descriptionRu'] as String?,
        descriptionEn: data['descriptionEn'] as String?,
        type: data['type'] as String? ?? 'restaurant',
        address: localizedField(
          locale,
          uz: data['address'] as String?,
          ru: data['addressRu'] as String?,
          en: data['addressEn'] as String?,
        ),
        addressUz: data['address'] as String? ?? '',
        addressRu: data['addressRu'] as String?,
        addressEn: data['addressEn'] as String?,
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
          // Always keep Uzbek as source name for edit forms
          name: map['name'] as String? ?? '',
          nameRu: map['nameRu'] as String?,
          nameEn: map['nameEn'] as String?,
          merchantId: map['merchantId'] as String?,
          sortOrder: map['sortOrder'] as int? ?? 0,
          productCount: 0,
        );
      }).toList();
    } on DioException {
      return [];
    }
  }

  Future<List<CatalogIngredient>> fetchIngredients() async {
    try {
      final response =
          await _api.get<List<dynamic>>('/partner/products/ingredients');
      return (response.data ?? []).map((raw) {
        final map = raw as Map<String, dynamic>;
        return CatalogIngredient(
          id: map['id'] as String,
          name: map['name'] as String? ?? '',
          nameRu: map['nameRu'] as String?,
          nameEn: map['nameEn'] as String?,
          merchantId: map['merchantId'] as String?,
        );
      }).toList();
    } on DioException {
      return [];
    }
  }

  Future<CatalogIngredient?> saveIngredient(CatalogIngredient item) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/partner/products/ingredients',
        data: {
          if (item.id.isNotEmpty) 'id': item.id,
          'name': item.name,
          'nameRu': item.nameRu,
          'nameEn': item.nameEn,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return CatalogIngredient(
        id: data['id'] as String,
        name: data['name'] as String? ?? item.name,
        nameRu: data['nameRu'] as String?,
        nameEn: data['nameEn'] as String?,
        merchantId: data['merchantId'] as String?,
      );
    } on DioException {
      return null;
    }
  }

  Future<bool> deleteIngredient(String ingredientId) async {
    try {
      await _api.delete('/partner/products/ingredients/$ingredientId');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<MenuProduct>> fetchProducts() async {
    try {
      final response = await _api.get<List<dynamic>>('/partner/products');
      return (response.data ?? [])
          .map((raw) => _mapProduct(raw as Map<String, dynamic>))
          .toList();
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
          'nameRu': product.nameRu,
          'nameEn': product.nameEn,
          'description': product.description,
          'descriptionRu': product.descriptionRu,
          'descriptionEn': product.descriptionEn,
          'ingredientIds':
              product.ingredientIds.isEmpty ? null : product.ingredientIds,
          'ingredients':
              product.ingredients.isEmpty ? null : product.ingredients,
          'ingredientsRu':
              product.ingredientsRu.isEmpty ? null : product.ingredientsRu,
          'ingredientsEn':
              product.ingredientsEn.isEmpty ? null : product.ingredientsEn,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isAvailable': product.available,
          'weightGrams': product.weightGrams,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return _mapProduct(data);
    } on DioException {
      return null;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _api.delete('/partner/products/$productId');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<MenuCategory?> saveCategory(MenuCategory category) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/partner/products/categories',
        data: {
          if (category.id.isNotEmpty) 'id': category.id,
          'name': category.name,
          'nameRu': category.nameRu,
          'nameEn': category.nameEn,
          'sortOrder': category.sortOrder,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return MenuCategory(
        id: data['id'] as String,
        name: data['name'] as String? ?? category.name,
        nameRu: data['nameRu'] as String?,
        nameEn: data['nameEn'] as String?,
        merchantId: data['merchantId'] as String?,
        sortOrder: data['sortOrder'] as int? ?? category.sortOrder,
        productCount: category.productCount,
      );
    } on DioException {
      return null;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _api.delete('/partner/products/categories/$categoryId');
      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<DaySchedule>> fetchSchedule() async {
    try {
      final response =
          await _api.get<Map<String, dynamic>>('/partner/merchant/schedule');
      final days = response.data?['days'];
      if (days is! List) return _defaultWeek();
      final mapped = days.map((raw) {
        final map = raw as Map<String, dynamic>;
        return DaySchedule(
          weekday: map['weekday'] as int? ?? 1,
          openTime: _hhmm(map['openTime'] as String?) ?? '11:00',
          closeTime: _hhmm(map['closeTime'] as String?) ?? '20:00',
          isClosed: map['isClosed'] as bool? ?? false,
        );
      }).toList();
      return _fillWeek(mapped);
    } on DioException {
      return _defaultWeek();
    }
  }

  Future<({List<DaySchedule> days, bool isOpen, String? workingHoursText})?>
      saveSchedule({
    required List<DaySchedule> days,
    bool? isOpen,
  }) async {
    try {
      if (isOpen != null) {
        await updateMerchant(isOpen: isOpen);
      }
      final response = await _api.put<Map<String, dynamic>>(
        '/partner/merchant/schedule',
        data: {
          'days': [
            for (final day in days)
              {
                'weekday': day.weekday,
                'openTime': day.openTime,
                'closeTime': day.closeTime,
                'isClosed': day.isClosed,
              },
          ],
        },
      );
      final data = response.data;
      if (data == null) return null;
      final rawDays = data['days'];
      final mapped = rawDays is List
          ? rawDays.map((raw) {
              final map = raw as Map<String, dynamic>;
              return DaySchedule(
                weekday: map['weekday'] as int? ?? 1,
                openTime: _hhmm(map['openTime'] as String?) ?? '11:00',
                closeTime: _hhmm(map['closeTime'] as String?) ?? '20:00',
                isClosed: map['isClosed'] as bool? ?? false,
              );
            }).toList()
          : days;
      return (
        days: _fillWeek(mapped),
        isOpen: data['isOpen'] as bool? ?? isOpen ?? true,
        workingHoursText: data['workingHoursText'] as String?,
      );
    } on DioException {
      return null;
    }
  }

  String? _hhmm(String? value) {
    if (value == null || value.isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value.trim());
    if (match == null) return null;
    final h = match.group(1)!.padLeft(2, '0');
    final m = match.group(2)!;
    return '$h:$m';
  }

  List<DaySchedule> _defaultWeek() {
    return [
      for (var weekday = 1; weekday <= 7; weekday++)
        DaySchedule(
          weekday: weekday,
          openTime: weekday >= 6 ? '12:00' : '11:00',
          closeTime: '20:00',
          isClosed: false,
        ),
    ];
  }

  List<DaySchedule> _fillWeek(List<DaySchedule> days) {
    final byDay = {for (final d in days) d.weekday: d};
    return [
      for (var weekday = 1; weekday <= 7; weekday++)
        byDay[weekday] ??
            DaySchedule(
              weekday: weekday,
              openTime: weekday >= 6 ? '12:00' : '11:00',
              closeTime: '20:00',
              isClosed: false,
            ),
    ];
  }

  Future<MerchantProfile?> updateMerchant({
    String? name,
    String? nameRu,
    String? nameEn,
    String? description,
    String? descriptionRu,
    String? descriptionEn,
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
          if (nameRu != null) 'nameRu': nameRu,
          if (nameEn != null) 'nameEn': nameEn,
          if (description != null) 'description': description,
          if (descriptionRu != null) 'descriptionRu': descriptionRu,
          if (descriptionEn != null) 'descriptionEn': descriptionEn,
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
        name: localizedField(
          locale,
          uz: data['name'] as String?,
          ru: data['nameRu'] as String?,
          en: data['nameEn'] as String?,
          fallback: 'Merchant',
        ),
        nameUz: data['name'] as String? ?? '',
        nameRu: data['nameRu'] as String?,
        nameEn: data['nameEn'] as String?,
        description: data['description'] as String?,
        descriptionRu: data['descriptionRu'] as String?,
        descriptionEn: data['descriptionEn'] as String?,
        type: data['type'] as String? ?? 'restaurant',
        address: localizedField(
          locale,
          uz: data['address'] as String?,
          ru: data['addressRu'] as String?,
          en: data['addressEn'] as String?,
        ),
        addressUz: data['address'] as String? ?? '',
        addressRu: data['addressRu'] as String?,
        addressEn: data['addressEn'] as String?,
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
    required this.nameUz,
    this.nameRu,
    this.nameEn,
    this.description,
    this.descriptionRu,
    this.descriptionEn,
    required this.type,
    required this.address,
    required this.addressUz,
    this.addressRu,
    this.addressEn,
    required this.phone,
    this.logoUrl,
    this.coverUrl,
    this.isOpen = true,
    this.workingHoursText,
  });

  final String id;
  final String name;
  final String nameUz;
  final String? nameRu;
  final String? nameEn;
  final String? description;
  final String? descriptionRu;
  final String? descriptionEn;
  final String type;
  final String address;
  final String addressUz;
  final String? addressRu;
  final String? addressEn;
  final String phone;
  final String? logoUrl;
  final String? coverUrl;
  final bool isOpen;
  final String? workingHoursText;
}
