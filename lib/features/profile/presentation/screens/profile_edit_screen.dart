import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/inputs/app_inputs.dart';
import 'package:eda_restaurant/features/menu/data/menu_api_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _name = TextEditingController();
  final _nameRu = TextEditingController();
  final _nameEn = TextEditingController();
  final _description = TextEditingController();
  final _descriptionRu = TextEditingController();
  final _descriptionEn = TextEditingController();
  final _logoUrl = TextEditingController();
  final _coverUrl = TextEditingController();
  String _lang = 'uz';
  bool _loading = true;
  bool _saving = false;
  String _address = '';
  String _type = 'restaurant';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    _nameRu.dispose();
    _nameEn.dispose();
    _description.dispose();
    _descriptionRu.dispose();
    _descriptionEn.dispose();
    _logoUrl.dispose();
    _coverUrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile =
        await ref.read(menuApiRepositoryProvider).fetchMerchantProfile();
    if (profile != null) {
      _name.text = profile.nameUz;
      _nameRu.text = profile.nameRu ?? '';
      _nameEn.text = profile.nameEn ?? '';
      _description.text = profile.description ?? '';
      _descriptionRu.text = profile.descriptionRu ?? '';
      _descriptionEn.text = profile.descriptionEn ?? '';
      _logoUrl.text = profile.logoUrl ?? '';
      _coverUrl.text = profile.coverUrl ?? '';
      _address = profile.address;
      _type = profile.type;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ToastScope.of(context).error('O‘zbekcha nom majburiy');
      return;
    }
    setState(() => _saving = true);
    final saved = await ref.read(menuApiRepositoryProvider).updateMerchant(
          name: _name.text.trim(),
          nameRu: _nameRu.text.trim().isEmpty ? null : _nameRu.text.trim(),
          nameEn: _nameEn.text.trim().isEmpty ? null : _nameEn.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          descriptionRu: _descriptionRu.text.trim().isEmpty
              ? null
              : _descriptionRu.text.trim(),
          descriptionEn: _descriptionEn.text.trim().isEmpty
              ? null
              : _descriptionEn.text.trim(),
          logoUrl: _logoUrl.text.trim().isEmpty ? null : _logoUrl.text.trim(),
          coverUrl:
              _coverUrl.text.trim().isEmpty ? null : _coverUrl.text.trim(),
        );
    setState(() => _saving = false);
    if (!mounted) return;
    if (saved == null) {
      ToastScope.of(context).error('Saqlash amalga oshmadi');
      return;
    }
    ref.invalidate(merchantProfileProvider);
    ToastScope.of(context).success('Profil saqlandi');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilni tahrirlash')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                120,
              ),
              children: [
                Text(
                  'Manzil faqat admin tomonidan o‘zgartiriladi',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(_address.isEmpty ? '—' : _address),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tur: $_type',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xl),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'uz', label: Text("Oʻzbek")),
                    ButtonSegment(value: 'ru', label: Text('Русский')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {_lang},
                  onSelectionChanged: (value) =>
                      setState(() => _lang = value.first),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_lang == 'uz') ...[
                  AnimatedTextField(
                    controller: _name,
                    label: 'Nomi (UZ) *',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedTextField(
                    controller: _description,
                    label: 'Tavsif (UZ)',
                    maxLines: 3,
                  ),
                ] else if (_lang == 'ru') ...[
                  AnimatedTextField(
                    controller: _nameRu,
                    label: 'Название (RU)',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedTextField(
                    controller: _descriptionRu,
                    label: 'Описание (RU)',
                    maxLines: 3,
                  ),
                ] else ...[
                  AnimatedTextField(
                    controller: _nameEn,
                    label: 'Name (EN)',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedTextField(
                    controller: _descriptionEn,
                    label: 'Description (EN)',
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AnimatedTextField(
                  controller: _logoUrl,
                  label: 'Logo URL',
                ),
                const SizedBox(height: AppSpacing.md),
                AnimatedTextField(
                  controller: _coverUrl,
                  label: 'Banner URL',
                ),
              ].animate(interval: 40.ms).fadeIn().slideY(begin: 0.02),
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.page),
        child: PrimaryButton(
          label: 'Saqlash',
          icon: Icons.save_rounded,
          isLoading: _saving,
          isEnabled: !_saving && !_loading,
          onPressed: _save,
        ),
      ),
    );
  }
}
