import 'package:cached_network_image/cached_network_image.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/features/menu/data/menu_api_repository.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(restaurantStatusProvider);
    final merchantAsync = ref.watch(merchantProfileProvider);
    final merchant = merchantAsync.value;
    final profile = RestaurantProfile(
      id: merchant?.id ?? 'merchant',
      name: merchant?.name ?? 'Partner',
      phone: merchant?.phone ?? '',
      address: merchant?.address ?? '',
      logoUrl: merchant?.logoUrl ?? '',
      coverUrl: merchant?.coverUrl ?? '',
      status: status,
      type: merchant?.type ?? 'restaurant',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Tahrirlash',
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          120,
        ),
        children: [
          _ProfileHero(profile: profile),
          const SizedBox(height: AppSpacing.lg),
          MenuTile(
            title: 'Profilni tahrirlash',
            subtitle: 'Nom, tavsif, logo va banner',
            icon: Icons.storefront_rounded,
            onTap: () => context.push('/profile/edit'),
          ),
          MenuTile(
            title: 'Ish jadvali',
            subtitle: merchant?.workingHoursText ?? 'Kunlik ochilish vaqtlari',
            icon: Icons.schedule_rounded,
            onTap: () => context.go('/schedule'),
          ),
          MenuTile(
            title: 'Menyu',
            subtitle: 'Mahsulot qo‘shish va o‘chirish',
            icon: Icons.restaurant_menu_rounded,
            onTap: () => context.go('/menu'),
          ),
          MenuTile(
            title: 'Kategoriyalar',
            subtitle: profile.type == 'pharmacy'
                ? 'Apteka bo‘limlari (masalan: dori, gigiyena)'
                : profile.type == 'market'
                    ? 'Do‘kon bo‘limlari (masalan: ichimlik, non)'
                    : 'Menyu bo‘limlari (masalan: ichimliklar, salat)',
            icon: Icons.category_rounded,
            onTap: () => context.push('/menu/category'),
          ),
          if (profile.type == 'restaurant')
            MenuTile(
              title: 'Ingredientlar',
              subtitle: 'Mahsulot tarkibi (faqat restoran)',
              icon: Icons.spa_rounded,
              onTap: () => context.push('/menu/ingredients'),
            ),
          MenuTile(
            title: 'Sozlamalar',
            subtitle: 'Til, mavzu, ovoz',
            icon: Icons.settings_rounded,
            onTap: () => context.push('/settings'),
          ),
          MenuTile(
            title: 'Chiqish',
            subtitle: 'Akkountdan chiqish',
            icon: Icons.logout_rounded,
            onTap: () async {
              await clearAuth(ref);
              if (context.mounted) context.go('/login');
            },
          ),
        ].animate(interval: 45.ms).fadeIn().slideY(begin: 0.03),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final RestaurantProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CachedNetworkImage(
                imageUrl: profile.coverUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                left: AppSpacing.xl,
                bottom: -38,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 39,
                    backgroundImage: CachedNetworkImageProvider(
                      profile.logoUrl,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              52,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    StatusBadge(
                      label: profile.status.label,
                      color: profile.status.color,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(profile.phone),
                const SizedBox(height: AppSpacing.sm),
                Text(profile.address),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
