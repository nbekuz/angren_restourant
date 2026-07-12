import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier();
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
  MenuNotifier()
    : super(
        const MenuState(
          categories: DemoData.categories,
          products: DemoData.products,
        ),
      );

  static const _uuid = Uuid();

  void saveProduct(MenuProduct product) {
    final id = product.id.isEmpty ? 'prod_${_uuid.v4()}' : product.id;
    final normalized = product.copyWith(id: id);
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
    state = state.copyWith(
      products: [
        for (final product in state.products)
          if (product.id == productId)
            product.copyWith(available: available)
          else
            product,
      ],
    );
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
