import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/shared/providers/menu_providers.dart';
import 'package:eda_restaurant/shared/providers/order_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _range = 'Today';

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardStatsProvider);
    final products = ref.watch(menuProvider).products;
    final categories = ref.watch(menuProvider).categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          120,
        ),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Today', label: Text('Today')),
              ButtonSegment(value: 'Week', label: Text('Week')),
              ButtonSegment(value: 'Month', label: Text('Month')),
            ],
            selected: {_range},
            onSelectionChanged: (value) => setState(() => _range = value.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          RevenueCard(
            title: 'Revenue $_range',
            amount: stats.todayRevenue * _multiplier,
            subtitle:
                '${stats.todayOrders * _multiplier.round()} orders · avg ${formatMoney(stats.avgCheck)}',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ChartCard(title: 'Revenue curve', child: const _RevenueChart()),
          const SizedBox(height: AppSpacing.lg),
          _ChartCard(title: 'Orders by hour', child: const _OrdersChart()),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  label: 'Avg check',
                  value: formatMoney(stats.avgCheck),
                  icon: Icons.payments_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatisticCard(
                  label: 'Completed',
                  value: stats.completed.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ChartCard(
            title: 'Top products',
            child: Column(
              children: [
                for (final product in products.take(5))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(product.name),
                    subtitle: Text('${product.stock} in stock'),
                    trailing: Text(formatMoney(product.price)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ChartCard(
            title: 'Popular categories',
            child: Column(
              children: [
                for (final category in categories)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_fire_department_rounded),
                    title: Text(category.name),
                    trailing: Text('${category.productCount} items'),
                  ),
              ],
            ),
          ),
        ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.025),
      ),
    );
  }

  double get _multiplier => switch (_range) {
    'Week' => 7,
    'Month' => 30,
    _ => 1,
  };
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              dotData: const FlDotData(show: false),
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 2.8),
                FlSpot(2, 2.4),
                FlSpot(3, 4.2),
                FlSpot(4, 3.8),
                FlSpot(5, 5.2),
                FlSpot(6, 6.1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersChart extends StatelessWidget {
  const _OrdersChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < 7; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (i + 2) * 2.0,
                    width: 18,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    color: i.isEven ? AppColors.accent : AppColors.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
