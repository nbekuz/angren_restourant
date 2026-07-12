import 'package:cached_network_image/cached_network_image.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/inputs/app_inputs.dart';
import 'package:eda_restaurant/shared/models/models.dart';
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
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _image = TextEditingController();
  final _stock = TextEditingController();
  final _weight = TextEditingController();
  final _discount = TextEditingController();
  final _ingredients = TextEditingController();
  String? _categoryId;
  bool _available = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _image.dispose();
    _stock.dispose();
    _weight.dispose();
    _discount.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menu = ref.watch(menuProvider);
    final existing = widget.productId == null || widget.productId == 'new'
        ? null
        : ref.watch(productByIdProvider(widget.productId!));
    final title = existing == null ? 'New product' : existing.name;

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
            AnimatedTextField(
              controller: _name,
              label: 'Name',
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedTextField(
              controller: _description,
              label: 'Description',
              maxLines: 3,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in menu.categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
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
            const SizedBox(height: AppSpacing.lg),
            AnimatedTextField(
              controller: _ingredients,
              label: 'Ingredients',
              hint: 'Comma-separated',
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
        child: PrimaryButton(
          label: 'Save product',
          icon: Icons.save_rounded,
          onPressed: () => _save(existing),
        ),
      ),
    );
  }

  void _hydrate() {
    final menu = ref.read(menuProvider);
    final existing = widget.productId == null || widget.productId == 'new'
        ? null
        : ref.read(productByIdProvider(widget.productId!));
    final product = existing;
    _categoryId =
        product?.categoryId ??
        (menu.categories.isEmpty ? null : menu.categories.first.id);
    if (product != null) {
      _name.text = product.name;
      _description.text = product.description;
      _price.text = product.price.toStringAsFixed(0);
      _image.text = product.imageUrl;
      _stock.text = product.stock.toString();
      _weight.text = product.weightGrams.toString();
      _discount.text = product.discountPercent.toString();
      _ingredients.text = product.ingredients.join(', ');
      _available = product.available;
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

  void _save(MenuProduct? existing) {
    if (!(_formKey.currentState?.validate() ?? false) || _categoryId == null) {
      return;
    }
    final product = MenuProduct(
      id: existing?.id ?? '',
      categoryId: _categoryId!,
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? 0,
      imageUrl: _image.text.trim(),
      weightGrams: int.tryParse(_weight.text.trim()) ?? 0,
      available: _available,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      discountPercent: int.tryParse(_discount.text.trim()) ?? 0,
      ingredients: _ingredients.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );
    ref.read(menuProvider.notifier).saveProduct(product);
    ToastScope.of(context).success('Product saved', subtitle: product.name);
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
