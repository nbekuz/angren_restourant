import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/core/widgets/inputs/app_inputs.dart';
import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:eda_restaurant/shared/providers/order_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  static const _tabs = [
    PartnerOrderStatus.incoming,
    PartnerOrderStatus.preparing,
    PartnerOrderStatus.ready,
    PartnerOrderStatus.completed,
    PartnerOrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final status = ref.watch(restaurantStatusProvider);
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_rounded),
          ),
          IconButton(
            tooltip: 'Filter',
            onPressed: () => ToastScope.of(context).info(
              'Smart filter',
              subtitle: 'Search and status tabs are active in demo mode.',
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        0,
                      ),
                      child: Column(
                        children: [
                          _DashboardHeader(
                            status: status,
                            stats: stats,
                            onStatusChanged: (open) => persistRestaurantStatus(
                              ref,
                              open
                                  ? RestaurantStatus.open
                                  : RestaurantStatus.temporaryClosed,
                            ),
                            onMenu: () => context.go('/menu'),
                            onSchedule: () => context.go('/schedule'),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SearchField(
                            controller: _searchController,
                            hint: 'Search by order, customer, address',
                            onChanged: (value) =>
                                setState(() => _query = value.trim()),
                            onClear: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabsHeaderDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textMuted,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          for (final status in _tabs)
                            Tab(text: _labelWithCount(status, orders)),
                        ],
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    for (final status in _tabs)
                      _OrdersList(
                        orders: _filtered(orders, status),
                        onAccept: (order) => _accept(order),
                        onReject: (order) => _reject(order),
                        onTap: (order) => context.push('/orders/${order.id}'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(ordersProvider.notifier).simulateIncoming();
          ToastScope.of(context).info(
            'Incoming order',
            subtitle: 'Fullscreen accept alert is now active.',
          );
        },
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Simulate'),
      ),
    );
  }

  String _labelWithCount(PartnerOrderStatus status, List<PartnerOrder> orders) {
    final count = orders.where((order) => order.status == status).length;
    return '${status.label} $count';
  }

  List<PartnerOrder> _filtered(
    List<PartnerOrder> orders,
    PartnerOrderStatus status,
  ) {
    final query = _query.toLowerCase();
    return orders.where((order) {
      final matchesStatus = order.status == status;
      final matchesQuery =
          query.isEmpty ||
          order.number.contains(query) ||
          order.customerName.toLowerCase().contains(query) ||
          order.address.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  Future<void> _accept(PartnerOrder order) async {
    await ref.read(ordersProvider.notifier).accept(order.id);
    if (!mounted) return;
    ToastScope.of(context).success('Accepted', subtitle: '#${order.number}');
  }

  Future<void> _reject(PartnerOrder order) async {
    await ref.read(ordersProvider.notifier).reject(order.id);
    if (!mounted) return;
    ToastScope.of(context).warning('Rejected', subtitle: '#${order.number}');
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.status,
    required this.stats,
    required this.onStatusChanged,
    required this.onMenu,
    required this.onSchedule,
  });

  final RestaurantStatus status;
  final DashboardStats stats;
  final ValueChanged<bool> onStatusChanged;
  final VoidCallback onMenu;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final isOpen = status == RestaurantStatus.open;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DemoData.profile.name,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    StatusBadge(label: status.label, color: status.color),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isOpen,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.success,
                onChanged: onStatusChanged,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: 'Today revenue',
                  value: formatMoney(stats.todayRevenue),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeaderMetric(
                  label: 'Pending',
                  value: stats.pending.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _QuickAction(
                icon: Icons.restaurant_menu_rounded,
                label: 'Menu',
                onTap: onMenu,
              ),
              const SizedBox(width: AppSpacing.md),
              _QuickAction(
                icon: Icons.schedule_rounded,
                label: 'Hours',
                onTap: onSchedule,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.04, end: 0);
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.onAccept,
    required this.onReject,
    required this.onTap,
  });

  final List<PartnerOrder> orders;
  final ValueChanged<PartnerOrder> onAccept;
  final ValueChanged<PartnerOrder> onReject;
  final ValueChanged<PartnerOrder> onTap;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyOrders();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        120,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () => onTap(order),
          onAccept: () => onAccept(order),
          onReject: () => onReject(order),
        ).animate(delay: (35 * index).ms).fadeIn().slideY(begin: 0.04);
      },
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No orders here',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'New orders will appear instantly with a fullscreen alert.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabsHeaderDelegate(this.child);

  final Widget child;

  @override
  double get minExtent => 54;

  @override
  double get maxExtent => 54;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
