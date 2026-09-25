import 'package:eda_restaurant/core/bottom_sheets/app_bottom_sheet.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/core/widgets/inputs/app_inputs.dart';
import 'package:eda_restaurant/features/menu/data/menu_api_repository.dart';
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
    final owned = categories.where((c) => c.isOwned).length;
    final type =
        ref.watch(merchantProfileProvider).value?.type ?? 'restaurant';

    return Scaffold(
      appBar: AppBar(title: const Text('Kategoriyalar')),
      body: categories.isEmpty
          ? _EmptyCategories(
              merchantType: type,
              onAdd: () => _openEditor(context, ref, null),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                120,
              ),
              header: _SummaryBanner(total: categories.length, owned: owned),
              itemCount: categories.length,
              onReorderItem: (oldIndex, newIndex) {
                ref
                    .read(menuProvider.notifier)
                    .reorderCategory(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  key: ValueKey(category.id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: CategoryCard(
                    category: category,
                    onTap: () => _openEditor(context, ref, category),
                  ).animate().fadeIn().slideX(begin: 0.03),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kategoriya qo‘shish'),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    MenuCategory? category,
  ) async {
    final result = await showAppBottomSheet<_CategorySheetResult>(
      context: context,
      initialChildSize: 0.72,
      child: _CategoryEditorSheet(category: category),
    );
    if (result == null || !context.mounted) return;

    final toast = ToastScope.of(context);
    if (result.delete && category != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kategoriyani o‘chirish'),
          content: Text('«${category.name}» o‘chirilsinmi?'),
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
      final ok =
          await ref.read(menuProvider.notifier).deleteCategory(category.id);
      if (!context.mounted) return;
      if (ok) {
        toast.warning('Kategoriya o‘chirildi');
      } else {
        toast.error('O‘chirish amalga oshmadi');
      }
      return;
    }

    if (!result.save) return;
    if (result.nameUz.trim().isEmpty) {
      toast.error('O‘zbekcha nom majburiy');
      return;
    }

    final ok = await ref.read(menuProvider.notifier).saveCategory(
          MenuCategory(
            id: category?.id ?? '',
            name: result.nameUz.trim(),
            nameRu:
                result.nameRu.trim().isEmpty ? null : result.nameRu.trim(),
            nameEn:
                result.nameEn.trim().isEmpty ? null : result.nameEn.trim(),
            merchantId: category?.merchantId,
            sortOrder: category?.sortOrder ??
                ref.read(menuProvider).categories.length + 1,
            productCount: category?.productCount ?? 0,
          ),
        );
    if (!context.mounted) return;
    if (ok) {
      toast.success(
        category == null ? 'Kategoriya qo‘shildi' : 'Kategoriya saqlandi',
      );
    } else {
      toast.error('Saqlash amalga oshmadi');
    }
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.total, required this.owned});

  final int total;
  final int owned;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.glow,
        ),
        child: Row(
          children: [
            const Icon(Icons.category_rounded, color: Colors.white, size: 36),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total kategoriya',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$owned ta sizniki · qolgani umumiy katalog',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.04);
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories({required this.onAdd, required this.merchantType});

  final VoidCallback onAdd;
  final String merchantType;

  @override
  Widget build(BuildContext context) {
    final hint = merchantType == 'pharmacy'
        ? 'Masalan: Dorilar, Vitaminlar, Gigiyena.\n3 tilda nom kiriting.'
        : merchantType == 'market'
            ? 'Masalan: Ichimliklar, Non, Meva.\n3 tilda nom kiriting.'
            : 'Masalan: Ichimliklar, 1-ovqat, Salatlar.\n3 tilda nom kiriting.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Hali kategoriya yo‘q',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Birinchi kategoriyani qo‘shish',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySheetResult {
  const _CategorySheetResult({
    required this.save,
    required this.delete,
    this.nameUz = '',
    this.nameRu = '',
    this.nameEn = '',
  });

  final bool save;
  final bool delete;
  final String nameUz;
  final String nameRu;
  final String nameEn;
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.category});

  final MenuCategory? category;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  String _lang = 'uz';
  bool _saving = false;

  bool get _canEdit =>
      widget.category == null || widget.category!.isOwned;

  @override
  void initState() {
    super.initState();
    _nameUz = TextEditingController(text: widget.category?.name ?? '');
    _nameRu = TextEditingController(text: widget.category?.nameRu ?? '');
    _nameEn = TextEditingController(text: widget.category?.nameEn ?? '');
    void refresh() {
      if (mounted) setState(() {});
    }

    _nameUz.addListener(refresh);
    _nameRu.addListener(refresh);
    _nameEn.addListener(refresh);
  }

  @override
  void dispose() {
    _nameUz.dispose();
    _nameRu.dispose();
    _nameEn.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canEdit || _saving) return;
    if (_nameUz.text.trim().isEmpty) {
      ToastScope.of(context).error('O‘zbekcha nom majburiy');
      return;
    }
    setState(() => _saving = true);
    Navigator.pop(
      context,
      _CategorySheetResult(
        save: true,
        delete: false,
        nameUz: _nameUz.text,
        nameRu: _nameRu.text,
        nameEn: _nameEn.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.category == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.page,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNew
                ? 'Yangi kategoriya'
                : _canEdit
                    ? 'Kategoriyani tahrirlash'
                    : 'Umumiy kategoriya',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _canEdit
                ? 'Nomni o‘zbek, rus va ingliz tillarida kiriting. UZ majburiy.'
                : 'Bu umumiy katalog kategoriyasi — faqat admin o‘zgartira oladi.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'uz', label: Text("Oʻzbek")),
              ButtonSegment(value: 'ru', label: Text('Русский')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {_lang},
            onSelectionChanged: (value) => setState(() => _lang = value.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_lang == 'uz')
            AnimatedTextField(
              controller: _nameUz,
              label: 'Nomi (UZ) *',
              hint: 'Masalan: Ichimliklar',
              enabled: _canEdit,
              prefixIcon: Icons.translate_rounded,
            )
          else if (_lang == 'ru')
            AnimatedTextField(
              controller: _nameRu,
              label: 'Название (RU)',
              hint: 'Например: Напитки',
              enabled: _canEdit,
              prefixIcon: Icons.translate_rounded,
            )
          else
            AnimatedTextField(
              controller: _nameEn,
              label: 'Name (EN)',
              hint: 'e.g. Drinks',
              enabled: _canEdit,
              prefixIcon: Icons.translate_rounded,
            ),
          const SizedBox(height: AppSpacing.md),
          _LangPreview(
            uz: _nameUz.text,
            ru: _nameRu.text,
            en: _nameEn.text,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_canEdit) ...[
            PrimaryButton(
              label: isNew ? 'Qo‘shish' : 'Saqlash',
              icon: isNew ? Icons.add_rounded : Icons.save_rounded,
              isLoading: _saving,
              onPressed: _submit,
            ),
            if (!isNew) ...[
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'O‘chirish',
                icon: Icons.delete_rounded,
                onPressed: () => Navigator.pop(
                  context,
                  const _CategorySheetResult(save: false, delete: true),
                ),
              ),
            ],
          ] else
            SecondaryButton(
              label: 'Yopish',
              onPressed: () => Navigator.pop(context),
            ),
          SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
        ],
      ),
    );
  }
}

class _LangPreview extends StatelessWidget {
  const _LangPreview({
    required this.uz,
    required this.ru,
    required this.en,
  });

  final String uz;
  final String ru;
  final String en;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ko‘rinish',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _previewLine('UZ', uz.isEmpty ? '—' : uz),
          _previewLine('RU', ru.isEmpty ? '—' : ru),
          _previewLine('EN', en.isEmpty ? '—' : en),
        ],
      ),
    );
  }

  Widget _previewLine(String code, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              code,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
