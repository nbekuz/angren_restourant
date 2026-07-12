import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          120,
        ),
        children: [
          _SettingsCard(
            title: 'Language',
            child: DropdownButtonFormField<Locale>(
              initialValue: locale,
              decoration: const InputDecoration(labelText: 'App language'),
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
                DropdownMenuItem(value: Locale('uz'), child: Text('Uzbek')),
              ],
              onChanged: (value) {
                if (value != null) persistLocale(ref, value);
              },
            ),
          ),
          _SettingsCard(
            title: 'Theme',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) => persistThemeMode(ref, value.first),
            ),
          ),
          _SwitchCard(
            title: 'Notifications',
            subtitle: 'New orders, courier updates, promotions',
            value: true,
            onChanged: (_) =>
                ToastScope.of(context).success('Notifications on'),
          ),
          _SwitchCard(
            title: 'Sound alerts',
            subtitle: 'Continuous incoming order sound and vibration',
            value: true,
            onChanged: (_) => ToastScope.of(context).success('Sound alerts on'),
          ),
          MenuTile(
            title: 'Printer',
            subtitle: 'Receipt printer not connected',
            icon: Icons.print_rounded,
            onTap: () => ToastScope.of(context).info(
              'Printer setup',
              subtitle: 'Bluetooth printer pairing opens here in production.',
            ),
          ),
          MenuTile(
            title: 'Logout',
            subtitle: 'Return to merchant login',
            icon: Icons.logout_rounded,
            onTap: () async {
              await clearAuth(ref);
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ].animate(interval: 45.ms).fadeIn().slideY(begin: 0.03),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SwitchCard extends StatefulWidget {
  const _SwitchCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_SwitchCard> createState() => _SwitchCardState();
}

class _SwitchCardState extends State<_SwitchCard> {
  late bool _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      value: _value,
      activeThumbColor: AppColors.primary,
      title: Text(widget.title),
      subtitle: Text(widget.subtitle),
      onChanged: (value) {
        setState(() => _value = value);
        widget.onChanged(value);
      },
    );
  }
}
