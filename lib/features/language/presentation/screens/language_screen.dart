import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(localeProvider).languageCode;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: AppShadows.button,
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.xl),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose the language for your restaurant workspace.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _LanguageOption(
                code: 'en',
                title: 'English',
                subtitle: 'Restaurant dashboard',
                selected: selected == 'en',
                onTap: () => _select(context, ref, const Locale('en')),
              ),
              _LanguageOption(
                code: 'ru',
                title: 'Русский',
                subtitle: 'Панель ресторана',
                selected: selected == 'ru',
                onTap: () => _select(context, ref, const Locale('ru')),
              ),
              _LanguageOption(
                code: 'uz',
                title: 'O‘zbekcha',
                subtitle: 'Restoran boshqaruvi',
                selected: selected == 'uz',
                onTap: () => _select(context, ref, const Locale('uz')),
              ),
              const Spacer(flex: 2),
            ],
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.04, end: 0),
        ),
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
  ) async {
    await persistLocale(ref, locale);
    if (!context.mounted) return;
    context.go(ref.read(isAuthenticatedProvider) ? '/dashboard' : '/login');
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedButton(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: selected ? AppShadows.soft : null,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: selected
                    ? AppColors.primary
                    : AppColors.surfaceSoft,
                child: Text(
                  code.toUpperCase(),
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
