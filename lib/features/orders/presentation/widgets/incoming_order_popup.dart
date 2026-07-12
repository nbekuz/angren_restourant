import 'dart:async';
import 'dart:ui';

import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:eda_restaurant/core/services/order_alert_service.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/features/orders/presentation/widgets/animated_countdown.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/order_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class IncomingOrderPopup extends ConsumerStatefulWidget {
  const IncomingOrderPopup({super.key});

  @override
  ConsumerState<IncomingOrderPopup> createState() => _IncomingOrderPopupState();
}

class _IncomingOrderPopupState extends ConsumerState<IncomingOrderPopup> {
  Timer? _timer;
  String? _activeOrderId;
  int _remaining = AppConstants.orderAcceptSeconds;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(incomingOrderProvider);
    _syncTimer(order);

    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: AppDurations.slow,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: order == null
            ? const SizedBox.shrink()
            : _PopupContent(
                key: ValueKey(order.id),
                order: order,
                remaining: _remaining,
                onAccept: () => _accept(order),
                onReject: order.allowReject ? () => _reject(order) : null,
              ),
      ),
    );
  }

  void _syncTimer(PartnerOrder? order) {
    if (order?.id == _activeOrderId) return;
    _timer?.cancel();
    _activeOrderId = order?.id;
    _remaining = AppConstants.orderAcceptSeconds;
    if (order == null) return;

    OrderAlertService.startIncomingAlert();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= 1) {
        timer.cancel();
        _reject(order, timedOut: true);
        return;
      }
      setState(() => _remaining--);
    });
  }

  Future<void> _accept(PartnerOrder order) async {
    _timer?.cancel();
    await ref.read(ordersProvider.notifier).accept(order.id);
    if (!mounted) return;
    ToastScope.of(context).success(
      'Order accepted',
      subtitle: 'Order #${order.number} moved to preparation.',
    );
    context.go('/orders/${order.id}');
  }

  Future<void> _reject(PartnerOrder order, {bool timedOut = false}) async {
    _timer?.cancel();
    await ref.read(ordersProvider.notifier).reject(order.id);
    if (!mounted) return;
    ToastScope.of(context).warning(
      timedOut ? 'Order timed out' : 'Order rejected',
      subtitle: 'Order #${order.number} was cancelled.',
    );
  }
}

class _PopupContent extends StatelessWidget {
  const _PopupContent({
    super.key,
    required this.order,
    required this.remaining,
    required this.onAccept,
    required this.onReject,
  });

  final PartnerOrder order;
  final int remaining;
  final VoidCallback onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.52),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.96),
                      AppColors.primaryDark.withValues(alpha: 0.92),
                      AppColors.accent.withValues(alpha: 0.86),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: Colors.white24),
                  boxShadow: AppShadows.floating,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: const Text(
                              'New order',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Spacer(),
                          AnimatedCountdown(
                            remainingSeconds: remaining,
                            totalSeconds: AppConstants.orderAcceptSeconds,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Order #${order.number}',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${order.customerName} · ${order.paymentMethod.label}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _InfoCard(order: order),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Items',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final item in order.items) _ItemRow(item: item),
                      const SizedBox(height: AppSpacing.xl),
                      _TotalRow(order: order),
                      const SizedBox(height: AppSpacing.xxl),
                      Row(
                        children: [
                          if (onReject != null) ...[
                            Expanded(
                              child: DangerButton(
                                label: 'Reject',
                                icon: Icons.close_rounded,
                                onPressed: onReject,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                          ],
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              label: 'Accept',
                              icon: Icons.check_rounded,
                              onPressed: onAccept,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.04),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.order});

  final PartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.phone_rounded, value: order.customerPhone),
          _InfoRow(icon: Icons.location_on_rounded, value: order.address),
          _InfoRow(
            icon: Icons.timer_rounded,
            value: 'ETA ${order.etaMinutes} minutes',
          ),
          if (order.notes != null)
            _InfoRow(icon: Icons.sticky_note_2_rounded, value: order.notes!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final PartnerOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              '${item.quantity}x',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          Text(
            formatMoney(item.price * item.quantity),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.order});

  final PartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Total',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white70),
        ),
        const Spacer(),
        Text(
          formatMoney(order.total),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
