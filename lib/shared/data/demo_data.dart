import 'package:eda_restaurant/shared/models/models.dart';

abstract final class DemoData {
  static final RestaurantProfile profile = RestaurantProfile(
    id: 'restaurant_bella_italia',
    name: 'Bella Italia',
    phone: '+998 90 777 22 11',
    address: 'Tashkent, Mirabad district, Nukus street 31',
    logoUrl:
        'https://images.unsplash.com/photo-1579684947550-22e945225d9a?w=240',
    coverUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200',
    status: RestaurantStatus.open,
    type: 'restaurant',
  );

  static final List<PartnerOrder> orders = [
    PartnerOrder(
      id: 'ord_10041',
      number: '10041',
      customerName: 'Aziza Karimova',
      customerPhone: '+998 93 451 18 20',
      address: 'Oybek metro, Afrosiyob Business Center, entrance B',
      items: const [
        PartnerOrderItem(name: 'Margherita Pizza', quantity: 1, price: 78000),
        PartnerOrderItem(name: 'Caesar Salad', quantity: 1, price: 52000),
      ],
      total: 130000,
      paymentMethod: PaymentMethod.online,
      status: PartnerOrderStatus.incoming,
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      notes: 'Add extra napkins',
      etaMinutes: 24,
      allowReject: true,
    ),
    PartnerOrder(
      id: 'ord_10040',
      number: '10040',
      customerName: 'Timur Saidov',
      customerPhone: '+998 97 552 90 03',
      address: 'C1, apartment 44, block 7',
      items: const [
        PartnerOrderItem(name: 'Chicken Alfredo', quantity: 2, price: 69000),
        PartnerOrderItem(name: 'Tiramisu', quantity: 1, price: 39000),
      ],
      total: 177000,
      paymentMethod: PaymentMethod.cash,
      status: PartnerOrderStatus.preparing,
      createdAt: DateTime.now().subtract(const Duration(minutes: 17)),
      etaMinutes: 16,
      allowReject: false,
    ),
    PartnerOrder(
      id: 'ord_10039',
      number: '10039',
      customerName: 'Malika Yunusova',
      customerPhone: '+998 90 119 35 22',
      address: 'Magic City residence, lobby 2',
      items: const [
        PartnerOrderItem(name: 'Pepperoni Pizza', quantity: 1, price: 89000),
        PartnerOrderItem(name: 'Berry Lemonade', quantity: 2, price: 24000),
      ],
      total: 137000,
      paymentMethod: PaymentMethod.online,
      status: PartnerOrderStatus.ready,
      createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
      etaMinutes: 4,
      allowReject: false,
    ),
    PartnerOrder(
      id: 'ord_10038',
      number: '10038',
      customerName: 'Otabek Ismoilov',
      customerPhone: '+998 99 887 00 12',
      address: 'Yakkasaray, Shota Rustaveli 12',
      items: const [
        PartnerOrderItem(name: 'Truffle Risotto', quantity: 1, price: 96000),
        PartnerOrderItem(name: 'Bruschetta', quantity: 1, price: 42000),
      ],
      total: 138000,
      paymentMethod: PaymentMethod.cash,
      status: PartnerOrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 8)),
      etaMinutes: 0,
      allowReject: false,
    ),
    PartnerOrder(
      id: 'ord_10037',
      number: '10037',
      customerName: 'Diyor Akramov',
      customerPhone: '+998 91 334 82 11',
      address: 'Tashkent City, Gardens Residence',
      items: const [
        PartnerOrderItem(name: 'Seafood Pasta', quantity: 1, price: 118000),
      ],
      total: 118000,
      paymentMethod: PaymentMethod.cash,
      status: PartnerOrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 12)),
      notes: 'Customer cancelled before preparation',
      etaMinutes: 0,
      allowReject: false,
    ),
    PartnerOrder(
      id: 'ord_10036',
      number: '10036',
      customerName: 'Sofia Petrova',
      customerPhone: '+998 98 001 42 75',
      address: 'Minor avenue, office 905',
      items: const [
        PartnerOrderItem(name: 'Caprese Sandwich', quantity: 3, price: 47000),
        PartnerOrderItem(name: 'Americano', quantity: 3, price: 18000),
      ],
      total: 195000,
      paymentMethod: PaymentMethod.online,
      status: PartnerOrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      etaMinutes: 0,
      allowReject: false,
    ),
  ];

  static const List<MenuCategory> categories = [
    MenuCategory(id: 'cat_pizza', name: 'Pizza', sortOrder: 1, productCount: 3),
    MenuCategory(id: 'cat_pasta', name: 'Pasta', sortOrder: 2, productCount: 3),
    MenuCategory(
      id: 'cat_salads',
      name: 'Salads',
      sortOrder: 3,
      productCount: 2,
    ),
    MenuCategory(
      id: 'cat_desserts',
      name: 'Desserts',
      sortOrder: 4,
      productCount: 2,
    ),
    MenuCategory(
      id: 'cat_drinks',
      name: 'Drinks',
      sortOrder: 5,
      productCount: 2,
    ),
  ];

  static const List<MenuProduct> products = [
    MenuProduct(
      id: 'prod_margherita',
      categoryId: 'cat_pizza',
      name: 'Margherita Pizza',
      description: 'San Marzano tomatoes, mozzarella fior di latte, basil.',
      price: 78000,
      imageUrl:
          'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=600',
      weightGrams: 520,
      available: true,
      stock: 24,
      discountPercent: 0,
      ingredients: ['Tomato', 'Mozzarella', 'Basil', 'Olive oil'],
    ),
    MenuProduct(
      id: 'prod_pepperoni',
      categoryId: 'cat_pizza',
      name: 'Pepperoni Pizza',
      description: 'Crisp pepperoni, mozzarella, house tomato sauce.',
      price: 89000,
      imageUrl:
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600',
      weightGrams: 560,
      available: true,
      stock: 18,
      discountPercent: 10,
      ingredients: ['Pepperoni', 'Mozzarella', 'Tomato sauce'],
    ),
    MenuProduct(
      id: 'prod_alfredo',
      categoryId: 'cat_pasta',
      name: 'Chicken Alfredo',
      description: 'Creamy parmesan sauce, grilled chicken, tagliatelle.',
      price: 69000,
      imageUrl:
          'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=600',
      weightGrams: 430,
      available: true,
      stock: 31,
      discountPercent: 0,
      ingredients: ['Chicken', 'Cream', 'Parmesan', 'Tagliatelle'],
    ),
    MenuProduct(
      id: 'prod_risotto',
      categoryId: 'cat_pasta',
      name: 'Truffle Risotto',
      description: 'Arborio rice, porcini, truffle oil, aged parmesan.',
      price: 96000,
      imageUrl:
          'https://images.unsplash.com/photo-1633964913295-ceb43826e7c9?w=600',
      weightGrams: 390,
      available: true,
      stock: 12,
      discountPercent: 0,
      ingredients: ['Arborio rice', 'Porcini', 'Truffle oil', 'Parmesan'],
    ),
    MenuProduct(
      id: 'prod_caesar',
      categoryId: 'cat_salads',
      name: 'Caesar Salad',
      description: 'Romaine, parmesan, croutons, grilled chicken.',
      price: 52000,
      imageUrl:
          'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=600',
      weightGrams: 310,
      available: true,
      stock: 20,
      discountPercent: 0,
      ingredients: ['Romaine', 'Chicken', 'Parmesan', 'Croutons'],
    ),
    MenuProduct(
      id: 'prod_tiramisu',
      categoryId: 'cat_desserts',
      name: 'Tiramisu',
      description: 'Mascarpone cream, espresso-soaked savoiardi, cocoa.',
      price: 39000,
      imageUrl:
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600',
      weightGrams: 180,
      available: true,
      stock: 16,
      discountPercent: 0,
      ingredients: ['Mascarpone', 'Espresso', 'Savoiardi', 'Cocoa'],
    ),
  ];

  static const List<DaySchedule> weeklySchedule = [
    DaySchedule(
      weekday: 1,
      openTime: '10:00',
      closeTime: '23:00',
      isClosed: false,
    ),
    DaySchedule(
      weekday: 2,
      openTime: '10:00',
      closeTime: '23:00',
      isClosed: false,
    ),
    DaySchedule(
      weekday: 3,
      openTime: '10:00',
      closeTime: '23:00',
      isClosed: false,
    ),
    DaySchedule(
      weekday: 4,
      openTime: '10:00',
      closeTime: '23:00',
      isClosed: false,
    ),
    DaySchedule(
      weekday: 5,
      openTime: '10:00',
      closeTime: '00:00',
      isClosed: false,
    ),
    DaySchedule(
      weekday: 6,
      openTime: '11:00',
      closeTime: '00:00',
      isClosed: false,
    ),
    DaySchedule(
      weekday: 7,
      openTime: '11:00',
      closeTime: '22:00',
      isClosed: false,
    ),
  ];

  static const DashboardStats stats = DashboardStats(
    todayOrders: 42,
    todayRevenue: 5845000,
    pending: 3,
    preparing: 7,
    completed: 31,
    avgCheck: 139166,
  );

  static const List<PartnerDocument> documents = [
    PartnerDocument(
      id: 'doc_license',
      title: 'Business license',
      status: 'Approved',
      imageUrl: '',
    ),
    PartnerDocument(
      id: 'doc_tax',
      title: 'Tax certificate',
      status: 'Approved',
      imageUrl: '',
    ),
    PartnerDocument(
      id: 'doc_halal',
      title: 'Food safety certificate',
      status: 'Pending',
      imageUrl: '',
    ),
  ];

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'notif_1',
      title: 'Peak demand',
      body: 'Dinner demand is 24% higher near your restaurant.',
      read: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      type: 'insight',
    ),
    AppNotification(
      id: 'notif_2',
      title: 'Menu sync completed',
      body: 'Six products were updated across customer apps.',
      read: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'menu',
    ),
    AppNotification(
      id: 'notif_3',
      title: 'Document review',
      body: 'Food safety certificate is being reviewed by support.',
      read: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'documents',
    ),
  ];
}
