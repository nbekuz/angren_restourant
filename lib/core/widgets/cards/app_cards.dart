import 'package:cached_network_image/cached_network_image.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter/material.dart';

String formatMoney(double amount) => '${amount.toStringAsFixed(0)} сум';

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: icon, color: color),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class RevenueCard extends StatelessWidget {
  const RevenueCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
  });

  final String title;
  final double amount;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.button,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  formatMoney(amount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const _IconBox(
            icon: Icons.payments_rounded,
            color: Colors.white,
            background: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({super.key, required this.profile, this.onTap});

  final RestaurantProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onTap ?? () {},
      child: _PremiumCard(
        child: Row(
          children: [
            _ImageAvatar(imageUrl: profile.logoUrl, fallback: profile.name),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.address,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatusBadge(
                    label: profile.status.label,
                    color: profile.status.color,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedButton(
        onPressed: onTap ?? () {},
        child: _PremiumCard(
          child: Row(
            children: [
              _IconBox(icon: icon),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key, required this.document, this.onTap});

  final PartnerDocument document;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (document.status.toLowerCase()) {
      'approved' || 'verified' => AppColors.success,
      'rejected' => AppColors.error,
      'pending' || 'review' => AppColors.warning,
      _ => AppColors.offline,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedButton(
        onPressed: onTap ?? () {},
        child: _PremiumCard(
          child: Row(
            children: [
              _IconBox(icon: Icons.description_rounded, color: color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Status: ${document.status}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(label: document.status, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, this.onTap});

  final MenuCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onTap ?? () {},
      child: _PremiumCard(
        child: Row(
          children: [
            const _IconBox(icon: Icons.restaurant_menu_rounded),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${category.productCount} products',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: '#${category.sortOrder}',
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final MenuProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onTap ?? () {},
      child: _PremiumCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: 78,
                height: 78,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      StatusBadge(
                        label: product.available ? 'Available' : 'Hidden',
                        color: product.available
                            ? AppColors.success
                            : AppColors.offline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        formatMoney(product.price),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${product.weightGrams} g',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  final PartnerOrder order;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final color = order.status.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedButton(
        onPressed: onTap ?? () {},
        child: _PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBox(icon: order.status.icon, color: color),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.number}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          order.customerName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: order.status.label, color: color),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricRow(label: 'Address', value: order.address),
              _MetricRow(
                label: 'Items',
                value: '${order.items.length} positions',
              ),
              _MetricRow(label: 'Total', value: formatMoney(order.total)),
              if (order.status == PartnerOrderStatus.incoming) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    if (order.allowReject)
                      Expanded(
                        child: DangerButton(
                          label: 'Reject',
                          onPressed: onReject,
                          icon: Icons.close_rounded,
                        ),
                      ),
                    if (order.allowReject) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Accept',
                        onPressed: onAccept,
                        icon: Icons.check_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _ImageAvatar extends StatelessWidget {
  const _ImageAvatar({required this.imageUrl, required this.fallback});

  final String imageUrl;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 34,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: imageUrl.isEmpty
          ? null
          : CachedNetworkImageProvider(imageUrl),
      child: imageUrl.isEmpty
          ? Text(
              fallback.characters.first,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    this.color = AppColors.primary,
    this.background,
  });

  final IconData icon;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: AppSpacing.lg),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

extension RestaurantStatusUi on RestaurantStatus {
  String get label => switch (this) {
    RestaurantStatus.open => 'Open',
    RestaurantStatus.closed => 'Closed',
    RestaurantStatus.temporaryClosed => 'Temporary closed',
  };

  Color get color => switch (this) {
    RestaurantStatus.open => AppColors.success,
    RestaurantStatus.closed => AppColors.offline,
    RestaurantStatus.temporaryClosed => AppColors.warning,
  };
}

extension PartnerOrderStatusUi on PartnerOrderStatus {
  String get label => switch (this) {
    PartnerOrderStatus.incoming => 'Incoming',
    PartnerOrderStatus.preparing => 'Preparing',
    PartnerOrderStatus.ready => 'Ready',
    PartnerOrderStatus.completed => 'Completed',
    PartnerOrderStatus.cancelled => 'Cancelled',
  };

  Color get color => switch (this) {
    PartnerOrderStatus.incoming => AppColors.accent,
    PartnerOrderStatus.preparing => AppColors.warning,
    PartnerOrderStatus.ready => AppColors.primary,
    PartnerOrderStatus.completed => AppColors.success,
    PartnerOrderStatus.cancelled => AppColors.error,
  };

  IconData get icon => switch (this) {
    PartnerOrderStatus.incoming => Icons.notifications_active_rounded,
    PartnerOrderStatus.preparing => Icons.restaurant_rounded,
    PartnerOrderStatus.ready => Icons.shopping_bag_rounded,
    PartnerOrderStatus.completed => Icons.check_circle_rounded,
    PartnerOrderStatus.cancelled => Icons.cancel_rounded,
  };
}
