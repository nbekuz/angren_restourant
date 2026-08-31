import 'package:eda_restaurant/features/menu/data/menu_api_repository.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredProductsProvider = Provider<List<MenuProduct>>((ref) {
  final state = ref.watch(menuProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  if (selectedCategory == null) return state.products;
  return state.products
      .where((product) => product.categoryId == selectedCategory)
      .toList();
});

final productByIdProvider = Provider.family<MenuProduct?, String>((ref, id) {
  final products = ref.watch(menuProvider).products;
  for (final product in products) {
    if (product.id == id) return product;
  }
  return null;
});

class MenuState {
  const MenuState({required this.categories, required this.products});

  final List<MenuCategory> categories;
  final List<MenuProduct> products;

  MenuState copyWith({
    List<MenuCategory>? categories,
    List<MenuProduct>? products,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  MenuNotifier(this._ref)
      : super(const MenuState(categories: [], products: [])) {
    _load();
  }

  final Ref _ref;
  static const _uuid = Uuid();

  Future<void> _load() async {
    final repo = _ref.read(menuApiRepositoryProvider);
    final categories = await repo.fetchCategories();
    final products = await repo.fetchProducts();
    state = MenuState(categories: categories, products: products);
  }

  Future<void> refresh() => _load();

  Future<void> saveProduct(MenuProduct product) async {
    final saved = await _ref.read(menuApiRepositoryProvider).saveProduct(product);
    if (saved == null) return;
    final id = saved.id.isEmpty ? 'prod_${_uuid.v4()}' : saved.id;
    final normalized = saved.copyWith(id: id);
    final exists = state.products.any((item) => item.id == id);
    final products = exists
        ? [
            for (final item in state.products)
              if (item.id == id) normalized else item,
          ]
        : [normalized, ...state.products];
    state = state.copyWith(products: products);
    _recountCategories();
  }

  void deleteProduct(String productId) {
    state = state.copyWith(
      products: state.products.where((item) => item.id != productId).toList(),
    );
    _recountCategories();
  }

  void toggleAvailability(String productId, bool available) {
    final product = state.products.firstWhere((p) => p.id == productId);
    saveProduct(product.copyWith(available: available));
  }

  void saveCategory(MenuCategory category) {
    final id = category.id.isEmpty ? 'cat_${_uuid.v4()}' : category.id;
    final normalized = category.copyWith(id: id);
    final exists = state.categories.any((item) => item.id == id);
    final categories = exists
        ? [
            for (final item in state.categories)
              if (item.id == id) normalized else item,
          ]
        : [...state.categories, normalized];
    state = state.copyWith(categories: _resort(categories));
    _recountCategories();
  }

  void deleteCategory(String categoryId) {
    final fallback = state.categories
        .where((category) => category.id != categoryId)
        .firstOrNull;
    state = state.copyWith(
      categories: state.categories
          .where((category) => category.id != categoryId)
          .toList(),
      products: [
        for (final product in state.products)
          if (product.categoryId == categoryId && fallback != null)
            product.copyWith(categoryId: fallback.id)
          else if (product.categoryId != categoryId)
            product,
      ],
    );
    _recountCategories();
  }

  void reorderCategory(int oldIndex, int newIndex) {
    final categories = List<MenuCategory>.of(state.categories);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = categories.removeAt(oldIndex);
    categories.insert(newIndex, moved);
    state = state.copyWith(
      categories: [
        for (var i = 0; i < categories.length; i++)
          categories[i].copyWith(sortOrder: i + 1),
      ],
    );
  }

  void _recountCategories() {
    state = state.copyWith(
      categories: [
        for (final category in state.categories)
          category.copyWith(
            productCount: state.products
                .where((product) => product.categoryId == category.id)
                .length,
          ),
      ],
    );
  }

  List<MenuCategory> _resort(List<MenuCategory> categories) {
    final sorted = List<MenuCategory>.of(categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return [
      for (var i = 0; i < sorted.length; i++)
        sorted[i].copyWith(sortOrder: i + 1),
    ];
  }
}
