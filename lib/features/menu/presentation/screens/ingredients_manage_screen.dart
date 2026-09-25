import 'package:eda_restaurant/core/bottom_sheets/app_bottom_sheet.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/inputs/app_inputs.dart';
import 'package:eda_restaurant/features/menu/data/menu_api_repository.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final ingredientsProvider =
    StateNotifierProvider.autoDispose<IngredientsNotifier, IngredientsState>(
  (ref) => IngredientsNotifier(ref),
);

class IngredientsState {
  const IngredientsState({
    this.items = const [],
    this.loading = true,
  });

  final List<CatalogIngredient> items;
  final bool loading;

  IngredientsState copyWith({
    List<CatalogIngredient>? items,
    bool? loading,
  }) {
    return IngredientsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
    );
  }
}

class IngredientsNotifier extends StateNotifier<IngredientsState> {
  IngredientsNotifier(this._ref) : super(const IngredientsState()) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    final items =
        await _ref.read(menuApiRepositoryProvider).fetchIngredients();
    state = IngredientsState(items: items, loading: false);
  }

  Future<bool> save(CatalogIngredient item) async {
    final saved =
        await _ref.read(menuApiRepositoryProvider).saveIngredient(item);
    if (saved == null) return false;
    final exists = state.items.any((e) => e.id == saved.id);
    state = state.copyWith(
      items: exists
          ? [
              for (final e in state.items)
                if (e.id == saved.id) saved else e,
            ]
          : [...state.items, saved]
        ..sort((a, b) => a.name.compareTo(b.name)),
    );
    return true;
  }

  Future<bool> remove(String id) async {
    final ok = await _ref.read(menuApiRepositoryProvider).deleteIngredient(id);
    if (!ok) return false;
    state = state.copyWith(
      items: state.items.where((e) => e.id != id).toList(),
    );
    return true;
  }
}

class IngredientsManageScreen extends ConsumerWidget {
  const IngredientsManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchant = ref.watch(merchantProfileProvider).value;
    if (merchant != null && merchant.type != 'restaurant') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/menu');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final state = ref.watch(ingredientsProvider);
    final owned = state.items.where((e) => e.isOwned).length;
    final locale = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(title: const Text('Ingredientlar')),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? _EmptyIngredients(onAdd: () => _openEditor(context, ref, null))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    120,
                  ),
                  children: [
                    _SummaryBanner(
                      total: state.items.length,
                      owned: owned,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    for (final item in state.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _IngredientCard(
                          item: item,
                          locale: locale,
                          onTap: () => _openEditor(context, ref, item),
                        ),
                      ),
                  ].animate(interval: 30.ms).fadeIn().slideY(begin: 0.03),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ingredient qo‘shish'),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    CatalogIngredient? item,
  ) async {
    final result = await showAppBottomSheet<_IngredientSheetResult>(
      context: context,
      initialChildSize: 0.72,
      child: _IngredientEditorSheet(item: item),
    );
    if (result == null || !context.mounted) return;

    final toast = ToastScope.of(context);
    if (result.delete && item != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ingredientni o‘chirish'),
          content: Text('«${item.name}» o‘chirilsinmi?'),
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
      final ok = await ref.read(ingredientsProvider.notifier).remove(item.id);
      if (!context.mounted) return;
      if (ok) {
        toast.warning('Ingredient o‘chirildi');
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

    final ok = await ref.read(ingredientsProvider.notifier).save(
          CatalogIngredient(
            id: item?.id ?? '',
            name: result.nameUz.trim(),
            nameRu:
                result.nameRu.trim().isEmpty ? null : result.nameRu.trim(),
            nameEn:
                result.nameEn.trim().isEmpty ? null : result.nameEn.trim(),
            merchantId: item?.merchantId,
          ),
        );
    if (!context.mounted) return;
    if (ok) {
      toast.success(
        item == null ? 'Ingredient qo‘shildi' : 'Ingredient saqlandi',
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.button,
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_rounded, color: Colors.white, size: 36),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total ingredient',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$owned ta sizniki · faqat restoran uchun',
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

class _EmptyIngredients extends StatelessWidget {
  const _EmptyIngredients({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
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
                Icons.spa_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Hali ingredient yo‘q',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Masalan: go‘sht, piyoz, sabzi.\nKeyin mahsulotga tanlaysiz.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Birinchi ingredientni qo‘shish',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({
    required this.item,
    required this.locale,
    required this.onTap,
  });

  final CatalogIngredient item;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCard : AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.isOwned ? Icons.spa_rounded : Icons.public_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label(locale),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (item.nameRu?.isNotEmpty == true)
                          'RU: ${item.nameRu}',
                        if (item.nameEn?.isNotEmpty == true)
                          'EN: ${item.nameEn}',
                      ].join(' · ').ifEmpty('3 tilda to‘ldiring'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.isOwned
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.isOwned ? 'Sizniki' : 'Umumiy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: item.isOwned ? AppColors.success : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _IngredientSheetResult {
  const _IngredientSheetResult({
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

class _IngredientEditorSheet extends StatefulWidget {
  const _IngredientEditorSheet({this.item});

  final CatalogIngredient? item;

  @override
  State<_IngredientEditorSheet> createState() => _IngredientEditorSheetState();
}

class _IngredientEditorSheetState extends State<_IngredientEditorSheet> {
  late final TextEditingController _nameUz;
  late final TextEditingController _nameRu;
  late final TextEditingController _nameEn;
  String _lang = 'uz';
  bool _saving = false;

  bool get _canEdit => widget.item == null || widget.item!.isOwned;

  @override
  void initState() {
    super.initState();
    _nameUz = TextEditingController(text: widget.item?.name ?? '');
    _nameRu = TextEditingController(text: widget.item?.nameRu ?? '');
    _nameEn = TextEditingController(text: widget.item?.nameEn ?? '');
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
      _IngredientSheetResult(
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
    final isNew = widget.item == null;
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
                ? 'Yangi ingredient'
                : _canEdit
                    ? 'Ingredientni tahrirlash'
                    : 'Umumiy ingredient',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _canEdit
                ? 'Faqat restoran uchun. UZ/RU/EN nomlarini kiriting.'
                : 'Umumiy katalog — faqat admin o‘zgartira oladi.',
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
              hint: 'Masalan: go‘sht',
              enabled: _canEdit,
              prefixIcon: Icons.spa_rounded,
            )
          else if (_lang == 'ru')
            AnimatedTextField(
              controller: _nameRu,
              label: 'Название (RU)',
              hint: 'Например: мясо',
              enabled: _canEdit,
              prefixIcon: Icons.spa_rounded,
            )
          else
            AnimatedTextField(
              controller: _nameEn,
              label: 'Name (EN)',
              hint: 'e.g. meat',
              enabled: _canEdit,
              prefixIcon: Icons.spa_rounded,
            ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurfaceSoft
                  : AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.border,
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
                _line('UZ', _nameUz.text),
                _line('RU', _nameRu.text),
                _line('EN', _nameEn.text),
              ],
            ),
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
                  const _IngredientSheetResult(save: false, delete: true),
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

  Widget _line(String code, String value) {
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
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}
