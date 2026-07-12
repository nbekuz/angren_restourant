import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/shared/providers/menu_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            tooltip: 'Manage categories',
            onPressed: () => context.push('/menu/category'),
            icon: const Icon(Icons.category_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: _MenuSummary(products: menu.products),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ChoiceChip(
                      label: const Text('All'),
                      selected: selected == null,
                      onSelected: (_) =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              null,
                    );
                  }
                  final category = menu.categories[index - 1];
                  return ChoiceChip(
                    label: Text('${category.name} ${category.productCount}'),
                    selected: selected == category.id,
                    onSelected: (_) =>
                        ref.read(selectedCategoryProvider.notifier).state =
                            category.id,
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemCount: menu.categories.length + 1,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              120,
            ),
            sliver: SliverList.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child:
                      Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ProductCard(
                                  product: product,
                                  onTap: () => context.push(
                                    '/menu/product/${product.id}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Switch.adaptive(
                                value: product.available,
                                activeThumbColor: AppColors.primary,
                                onChanged: (value) => ref
                                    .read(menuProvider.notifier)
                                    .toggleAvailability(product.id, value),
                              ),
                            ],
                          )
                          .animate(delay: (35 * index).ms)
                          .fadeIn()
                          .slideY(begin: 0.04),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/menu/product/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
    );
  }
}

class _MenuSummary extends StatelessWidget {
  const _MenuSummary({required this.products});

  final List products;

  @override
  Widget build(BuildContext context) {
    final hidden = products.where((product) => !product.available).length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.glow,
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 42),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${products.length} products',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                Text(
                  '$hidden in stop-list · availability syncs instantly',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
