import 'package:eda_restaurant/core/i18n/localized_fields.dart';
import 'package:equatable/equatable.dart';

enum RestaurantStatus { open, closed, temporaryClosed }

enum PartnerOrderStatus { incoming, preparing, ready, completed, cancelled }

enum PaymentMethod { card, cash, online }

class PartnerOrderItem extends Equatable {
  const PartnerOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.note,
  });

  final String name;
  final int quantity;
  final double price;
  final String? note;

  PartnerOrderItem copyWith({
    String? name,
    int? quantity,
    double? price,
    String? note,
  }) {
    return PartnerOrderItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [name, quantity, price, note];
}

class PartnerOrder extends Equatable {
  const PartnerOrder({
    required this.id,
    required this.number,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.etaMinutes,
    required this.allowReject,
    this.notes,
  });

  final String id;
  final String number;
  final String customerName;
  final String customerPhone;
  final String address;
  final List<PartnerOrderItem> items;
  final double total;
  final PaymentMethod paymentMethod;
  final PartnerOrderStatus status;
  final DateTime createdAt;
  final String? notes;
  final int etaMinutes;
  final bool allowReject;

  PartnerOrder copyWith({
    String? id,
    String? number,
    String? customerName,
    String? customerPhone,
    String? address,
    List<PartnerOrderItem>? items,
    double? total,
    PaymentMethod? paymentMethod,
    PartnerOrderStatus? status,
    DateTime? createdAt,
    String? notes,
    int? etaMinutes,
    bool? allowReject,
  }) {
    return PartnerOrder(
      id: id ?? this.id,
      number: number ?? this.number,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      items: items ?? this.items,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      allowReject: allowReject ?? this.allowReject,
    );
  }

  @override
  List<Object?> get props => [
    id,
    number,
    customerName,
    customerPhone,
    address,
    items,
    total,
    paymentMethod,
    status,
    createdAt,
    notes,
    etaMinutes,
    allowReject,
  ];
}

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.id,
    required this.name,
    this.nameRu,
    this.nameEn,
    this.merchantId,
    required this.sortOrder,
    required this.productCount,
  });

  final String id;
  final String name;
  final String? nameRu;
  final String? nameEn;
  final String? merchantId;
  final int sortOrder;
  final int productCount;

  bool get isOwned => merchantId != null && merchantId!.isNotEmpty;

  String label(String locale) => localizedField(
        locale,
        uz: name,
        ru: nameRu,
        en: nameEn,
        fallback: name,
      );

  MenuCategory copyWith({
    String? id,
    String? name,
    String? nameRu,
    String? nameEn,
    String? merchantId,
    int? sortOrder,
    int? productCount,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      nameEn: nameEn ?? this.nameEn,
      merchantId: merchantId ?? this.merchantId,
      sortOrder: sortOrder ?? this.sortOrder,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, nameRu, nameEn, merchantId, sortOrder, productCount];
}

class MenuProduct extends Equatable {
  const MenuProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    this.nameRu,
    this.nameEn,
    required this.description,
    this.descriptionRu,
    this.descriptionEn,
    required this.price,
    required this.imageUrl,
    required this.weightGrams,
    required this.available,
    required this.stock,
    required this.discountPercent,
    required this.ingredients,
    this.ingredientsRu = const [],
    this.ingredientsEn = const [],
    this.ingredientIds = const [],
  });

  final String id;
  final String categoryId;
  final String name;
  final String? nameRu;
  final String? nameEn;
  final String description;
  final String? descriptionRu;
  final String? descriptionEn;
  final double price;
  final String imageUrl;
  final int weightGrams;
  final bool available;
  final int stock;
  final int discountPercent;
  final List<String> ingredients;
  final List<String> ingredientsRu;
  final List<String> ingredientsEn;
  final List<String> ingredientIds;

  String displayName(String locale) => localizedField(
        locale,
        uz: name,
        ru: nameRu,
        en: nameEn,
        fallback: name,
      );

  String displayDescription(String locale) => localizedField(
        locale,
        uz: description,
        ru: descriptionRu,
        en: descriptionEn,
      );

  MenuProduct copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? nameRu,
    String? nameEn,
    String? description,
    String? descriptionRu,
    String? descriptionEn,
    double? price,
    String? imageUrl,
    int? weightGrams,
    bool? available,
    int? stock,
    int? discountPercent,
    List<String>? ingredients,
    List<String>? ingredientsRu,
    List<String>? ingredientsEn,
    List<String>? ingredientIds,
  }) {
    return MenuProduct(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      nameRu: nameRu ?? this.nameRu,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      descriptionRu: descriptionRu ?? this.descriptionRu,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      weightGrams: weightGrams ?? this.weightGrams,
      available: available ?? this.available,
      stock: stock ?? this.stock,
      discountPercent: discountPercent ?? this.discountPercent,
      ingredients: ingredients ?? this.ingredients,
      ingredientsRu: ingredientsRu ?? this.ingredientsRu,
      ingredientsEn: ingredientsEn ?? this.ingredientsEn,
      ingredientIds: ingredientIds ?? this.ingredientIds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    nameRu,
    nameEn,
    description,
    descriptionRu,
    descriptionEn,
    price,
    imageUrl,
    weightGrams,
    available,
    stock,
    discountPercent,
    ingredients,
    ingredientsRu,
    ingredientsEn,
    ingredientIds,
  ];
}

class DaySchedule extends Equatable {
  const DaySchedule({
    required this.weekday,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  final int weekday;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  DaySchedule copyWith({
    int? weekday,
    String? openTime,
    String? closeTime,
    bool? isClosed,
  }) {
    return DaySchedule(
      weekday: weekday ?? this.weekday,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  List<Object?> get props => [weekday, openTime, closeTime, isClosed];
}

class RestaurantProfile extends Equatable {
  const RestaurantProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.logoUrl,
    required this.coverUrl,
    required this.status,
    required this.type,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final String logoUrl;
  final String coverUrl;
  final RestaurantStatus status;
  final String type;

  RestaurantProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? logoUrl,
    String? coverUrl,
    RestaurantStatus? status,
    String? type,
  }) {
    return RestaurantProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    address,
    logoUrl,
    coverUrl,
    status,
    type,
  ];
}

class PartnerDocument extends Equatable {
  const PartnerDocument({
    required this.id,
    required this.title,
    required this.status,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String status;
  final String imageUrl;

  PartnerDocument copyWith({
    String? id,
    String? title,
    String? status,
    String? imageUrl,
  }) {
    return PartnerDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, title, status, imageUrl];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    required this.type,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final String type;

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    bool? read,
    DateTime? createdAt,
    String? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, title, body, read, createdAt, type];
}

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.todayOrders,
    required this.todayRevenue,
    required this.pending,
    required this.preparing,
    required this.completed,
    required this.avgCheck,
  });

  final int todayOrders;
  final double todayRevenue;
  final int pending;
  final int preparing;
  final int completed;
  final double avgCheck;

  DashboardStats copyWith({
    int? todayOrders,
    double? todayRevenue,
    int? pending,
    int? preparing,
    int? completed,
    double? avgCheck,
  }) {
    return DashboardStats(
      todayOrders: todayOrders ?? this.todayOrders,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      pending: pending ?? this.pending,
      preparing: preparing ?? this.preparing,
      completed: completed ?? this.completed,
      avgCheck: avgCheck ?? this.avgCheck,
    );
  }

  @override
  List<Object?> get props => [
    todayOrders,
    todayRevenue,
    pending,
    preparing,
    completed,
    avgCheck,
  ];
}
