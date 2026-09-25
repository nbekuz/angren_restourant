import 'package:cached_network_image/cached_network_image.dart';
import 'package:eda_restaurant/core/i18n/localized_fields.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/inputs/app_inputs.dart';
import 'package:eda_restaurant/features/menu/data/menu_api_repository.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:eda_restaurant/shared/providers/menu_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _nameRu = TextEditingController();
  final _nameEn = TextEditingController();
  final _description = TextEditingController();
  final _descriptionRu = TextEditingController();
  final _descriptionEn = TextEditingController();
  final _price = TextEditingController();
  final _image = TextEditingController();
  final _stock = TextEditingController();
  final _weight = TextEditingController();
  final _discount = TextEditingController();
  String? _categoryId;
  bool _available = true;
  String _lang = 'uz';
  final Set<String> _ingredientIds = {};
  List<CatalogIngredient> _catalog = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  void dispose() {
    _name.dispose();
    _nameRu.dispose();
    _nameEn.dispose();
    _description.dispose();
    _descriptionRu.dispose();
    _descriptionEn.dispose();
    _price.dispose();
    _image.dispose();
    _stock.dispose();
    _weight.dispose();
    _discount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menu = ref.watch(menuProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final existing = widget.productId == null || widget.productId == 'new'
        ? null
        : ref.watch(productByIdProvider(widget.productId!));
    final title = existing == null
        ? 'New product'
        : localizedField(
            locale,
            uz: existing.name,
            ru: existing.nameRu,
            en: existing.nameEn,
            fallback: existing.name,
          );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            120,
          ),
          children: [
            _ImagePreview(imageController: _image),
            const SizedBox(height: AppSpacing.xl),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'uz', label: Text("Oʻzbek")),
                ButtonSegment(value: 'ru', label: Text('Русский')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {_lang},
              onSelectionChanged: (value) {
                setState(() => _lang = value.first);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_lang == 'uz') ...[
              AnimatedTextField(
                controller: _name,
                label: 'Name (UZ) *',
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedTextField(
                controller: _description,
                label: 'Description (UZ)',
                maxLines: 3,
              ),
            ] else if (_lang == 'ru') ...[
              AnimatedTextField(
                controller: _nameRu,
                label: 'Name (RU)',
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedTextField(
                controller: _descriptionRu,
                label: 'Description (RU)',
                maxLines: 3,
              ),
            ] else ...[
              AnimatedTextField(
                controller: _nameEn,
                label: 'Name (EN)',
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedTextField(
                controller: _descriptionEn,
                label: 'Description (EN)',
                maxLines: 3,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kategoriya',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/menu/category'),
                  child: const Text('Boshqarish'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownMenu<String>(
              key: ValueKey('cat-${_categoryId ?? 'none'}-${menu.categories.length}'),
              initialSelection: _categoryId,
              enableFilter: true,
              requestFocusOnTap: true,
              expandedInsets: EdgeInsets.zero,
              label: const Text('Kategoriya tanlang'),
              hintText: 'Qidirish…',
              leadingIcon: const Icon(Icons.search_rounded),
              dropdownMenuEntries: [
                for (final category in menu.categories)
                  DropdownMenuEntry<String>(
                    value: category.id,
                    label: category.label(
                      Localizations.localeOf(context).languageCode,
                    ),
                  ),
              ],
              onSelected: (value) => setState(() => _categoryId = value),
            ),
            if (menu.categories.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Avval kategoriya qo‘shing (Menyu → Kategoriya).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            if (ref.watch(merchantProfileProvider).value?.type ==
                'restaurant') ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ingredientlar',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/menu/ingredients'),
                    child: const Text('Boshqarish'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_catalog.isEmpty)
                const Text(
                  'Ingredient yo‘q. Menyu → Ingredientlar sahifasida qo‘shing.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in _catalog)
                      FilterChip(
                        label: Text(item.label(locale)),
                        selected: _ingredientIds.contains(item.id),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _ingredientIds.add(item.id);
                            } else {
                              _ingredientIds.remove(item.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AnimatedTextField(
                    controller: _price,
                    label: 'Price',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _required,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AnimatedTextField(
                    controller: _discount,
                    label: 'Discount %',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AnimatedTextField(
                    controller: _stock,
                    label: 'Stock',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AnimatedTextField(
                    controller: _weight,
                    label: 'Weight g',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedTextField(
              controller: _image,
              label: 'Image URL',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _available,
              activeThumbColor: AppColors.primary,
              title: const Text('Available'),
              subtitle: const Text('Turn off to add this item to stop-list'),
              onChanged: (value) => setState(() => _available = value),
            ),
          ].animate(interval: 40.ms).fadeIn().slideY(begin: 0.025),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: 'Mahsulotni saqlash',
              icon: Icons.save_rounded,
              onPressed: () => _save(existing),
            ),
            if (existing != null) ...[
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'O‘chirish',
                icon: Icons.delete_rounded,
                onPressed: () => _delete(existing),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _hydrate() async {
    final menu = ref.read(menuProvider);
    final existing = widget.productId == null || widget.productId == 'new'
        ? null
        : ref.read(productByIdProvider(widget.productId!));
    final catalog =
        await ref.read(menuApiRepositoryProvider).fetchIngredients();
    _categoryId =
        existing?.categoryId ??
        (menu.categories.isEmpty ? null : menu.categories.first.id);
    _catalog = catalog;
    if (existing != null) {
      _name.text = existing.name;
      _nameRu.text = existing.nameRu ?? '';
      _nameEn.text = existing.nameEn ?? '';
      _description.text = existing.description;
      _descriptionRu.text = existing.descriptionRu ?? '';
      _descriptionEn.text = existing.descriptionEn ?? '';
      _price.text = existing.price.toStringAsFixed(0);
      _image.text = existing.imageUrl;
      _stock.text = existing.stock.toString();
      _weight.text = existing.weightGrams.toString();
      _discount.text = existing.discountPercent.toString();
      _available = existing.available;
      _ingredientIds
        ..clear()
        ..addAll(existing.ingredientIds);
      if (_ingredientIds.isEmpty && existing.ingredients.isNotEmpty) {
        for (final name in existing.ingredients) {
          for (final item in catalog) {
            if (item.name.toLowerCase() == name.toLowerCase()) {
              _ingredientIds.add(item.id);
              break;
            }
          }
        }
      }
    } else {
      _price.text = '59000';
      _stock.text = '10';
      _weight.text = '300';
      _discount.text = '0';
      _image.text =
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600';
    }
    if (mounted) setState(() {});
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  Future<void> _save(MenuProduct? existing) async {
    if (!(_formKey.currentState?.validate() ?? false) || _categoryId == null) {
      return;
    }
    final selected = _catalog
        .where((item) => _ingredientIds.contains(item.id))
        .toList();
    final product = MenuProduct(
      id: existing?.id ?? '',
      categoryId: _categoryId!,
      name: _name.text.trim(),
      nameRu: _nameRu.text.trim().isEmpty ? null : _nameRu.text.trim(),
      nameEn: _nameEn.text.trim().isEmpty ? null : _nameEn.text.trim(),
      description: _description.text.trim(),
      descriptionRu:
          _descriptionRu.text.trim().isEmpty ? null : _descriptionRu.text.trim(),
      descriptionEn:
          _descriptionEn.text.trim().isEmpty ? null : _descriptionEn.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? 0,
      imageUrl: _image.text.trim(),
      weightGrams: int.tryParse(_weight.text.trim()) ?? 0,
      available: _available,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      discountPercent: int.tryParse(_discount.text.trim()) ?? 0,
      ingredientIds: selected.map((e) => e.id).toList(),
      ingredients: selected.map((e) => e.name).toList(),
      ingredientsRu: selected.map((e) => e.nameRu ?? e.name).toList(),
      ingredientsEn: selected.map((e) => e.nameEn ?? e.name).toList(),
    );
    final ok = await ref.read(menuProvider.notifier).saveProduct(product);
    if (!mounted) return;
    if (!ok) {
      ToastScope.of(context).error('Saqlash amalga oshmadi');
      return;
    }
    ToastScope.of(context).success('Mahsulot saqlandi', subtitle: product.name);
    context.pop();
  }

  Future<void> _delete(MenuProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mahsulotni o‘chirish'),
        content: Text('${product.name} o‘chirilsinmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('O‘chirish'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(menuProvider.notifier).deleteProduct(product.id);
    if (!mounted) return;
    if (!ok) {
      ToastScope.of(context).error('O‘chirish amalga oshmadi');
      return;
    }
    ToastScope.of(context).warning('Mahsulot o‘chirildi');
    context.pop();
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageController});

  final TextEditingController imageController;

  @override
  Widget build(BuildContext context) {
    final imageUrl = imageController.text.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: imageUrl.isEmpty
            ? Container(
                color: AppColors.surfaceSoft,
                child: const Icon(Icons.image_rounded, size: 56),
              )
            : CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
