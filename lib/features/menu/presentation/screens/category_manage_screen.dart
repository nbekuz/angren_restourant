import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/menu_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryManageScreen extends ConsumerWidget {
  const CategoryManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(menuProvider).categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          120,
        ),
        itemCount: categories.length,
        onReorderItem: ref.read(menuProvider.notifier).reorderCategory,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            key: ValueKey(category.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CategoryCard(
              category: category,
              onTap: () => _editCategory(context, ref, category),
            ).animate().fadeIn().slideX(begin: 0.04),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editCategory(context, ref, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add category'),
      ),
    );
  }

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref,
    MenuCategory? category,
  ) async {
    final toast = ToastScope.of(context);
    final controller = TextEditingController(text: category?.name ?? '');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.page,
            AppSpacing.page,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.page,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category == null ? 'New category' : 'Edit category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (category != null)
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context, '__delete__'),
                      icon: const Icon(Icons.delete_rounded),
                      label: const Text('Delete'),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, controller.text),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (result == null) return;
    if (result == '__delete__' && category != null) {
      ref.read(menuProvider.notifier).deleteCategory(category.id);
      toast.warning('Category deleted');
      return;
    }
    final name = result.trim();
    if (name.isEmpty) return;
    ref
        .read(menuProvider.notifier)
        .saveCategory(
          MenuCategory(
            id: category?.id ?? '',
            name: name,
            sortOrder:
                category?.sortOrder ??
                ref.read(menuProvider).categories.length + 1,
            productCount: category?.productCount ?? 0,
          ),
        );
    toast.success('Category saved', subtitle: name);
  }
}
