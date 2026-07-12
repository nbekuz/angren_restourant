import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/order_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.number}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          120,
        ),
        children: [
          _HeroCard(order: order),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: 'Customer',
            children: [
              _Metric(icon: Icons.person_rounded, text: order.customerName),
              _Metric(icon: Icons.phone_rounded, text: order.customerPhone),
              _Metric(icon: Icons.location_on_rounded, text: order.address),
              if (order.notes != null)
                _Metric(icon: Icons.notes_rounded, text: order.notes!),
            ],
          ),
          _Section(
            title: 'Items',
            children: [
              for (final item in order.items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('${item.quantity}x')),
                  title: Text(item.name),
                  subtitle: item.note == null ? null : Text(item.note!),
                  trailing: Text(formatMoney(item.price * item.quantity)),
                ),
            ],
          ),
          _Section(
            title: 'Timeline',
            children: [
              for (final entry in _timeline(order.status))
                _TimelineRow(entry: entry, active: entry.active),
            ],
          ),
          _Section(
            title: 'Courier',
            children: const [
              _Metric(
                icon: Icons.delivery_dining_rounded,
                text: 'Courier dispatch is queued after Ready status.',
              ),
            ],
          ),
        ].animate(interval: 45.ms).fadeIn().slideY(begin: 0.03),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.page),
        child: _Actions(order: order, ref: ref),
      ),
    );
  }

  List<_TimelineEntry> _timeline(PartnerOrderStatus status) {
    final statuses = [
      PartnerOrderStatus.incoming,
      PartnerOrderStatus.preparing,
      PartnerOrderStatus.ready,
      PartnerOrderStatus.completed,
    ];
    final current = statuses.indexOf(status);
    return [
      for (var i = 0; i < statuses.length; i++)
        _TimelineEntry(statuses[i].label, i <= current && current != -1),
    ];
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.order});

  final PartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.button,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(label: order.status.label, color: Colors.white),
              const Spacer(),
              Text(
                '${order.etaMinutes} min',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            formatMoney(order.total),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${order.items.length} positions · ${order.paymentMethod.label}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.order, required this.ref});

  final PartnerOrder order;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(ordersProvider.notifier);
    Future<void> setStatus(PartnerOrderStatus status) async {
      await notifier.setStatus(order.id, status);
      if (!context.mounted) return;
      ToastScope.of(context).success('Updated', subtitle: status.label);
    }

    return Row(
      children: [
        if (order.status == PartnerOrderStatus.incoming) ...[
          Expanded(
            child: DangerButton(
              label: 'Reject',
              icon: Icons.close_rounded,
              onPressed: () => notifier.reject(order.id),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(
              label: 'Accept',
              icon: Icons.check_rounded,
              onPressed: () => notifier.accept(order.id),
            ),
          ),
        ] else if (order.status == PartnerOrderStatus.preparing) ...[
          Expanded(
            child: PrimaryButton(
              label: 'Ready',
              icon: Icons.shopping_bag_rounded,
              onPressed: () => setStatus(PartnerOrderStatus.ready),
            ),
          ),
        ] else if (order.status == PartnerOrderStatus.ready) ...[
          Expanded(
            child: PrimaryButton(
              label: 'Complete',
              icon: Icons.check_circle_rounded,
              onPressed: () => setStatus(PartnerOrderStatus.completed),
            ),
          ),
        ] else ...[
          Expanded(
            child: SecondaryButton(
              label: 'Print receipt',
              icon: Icons.print_rounded,
              onPressed: () => ToastScope.of(context).info(
                'Receipt queued',
                subtitle: 'Printer integration is ready for production wiring.',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry(this.label, this.active);

  final String label;
  final bool active;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.active});

  final _TimelineEntry entry;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: active ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            entry.label,
            style: TextStyle(
              fontWeight: active ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

extension on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.card => 'Card',
    PaymentMethod.cash => 'Cash',
    PaymentMethod.online => 'Online paid',
  };
}
