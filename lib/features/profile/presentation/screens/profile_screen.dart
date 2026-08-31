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
      appBar: AppBar(title: const Text('Profile')),
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
            title: 'Documents',
            subtitle: 'Licenses, tax details, food safety',
            icon: Icons.description_rounded,
            onTap: () => context.push('/documents'),
          ),
          MenuTile(
            title: 'Notifications',
            subtitle: 'Orders, promotions, system updates',
            icon: Icons.notifications_rounded,
            onTap: () => context.push('/notifications'),
          ),
          MenuTile(
            title: 'Settings',
            subtitle: 'Language, theme, sound, printer',
            icon: Icons.settings_rounded,
            onTap: () => context.push('/settings'),
          ),
          MenuTile(
            title: 'Support',
            subtitle: '+998 71 200 77 77',
            icon: Icons.support_agent_rounded,
            onTap: () {},
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
