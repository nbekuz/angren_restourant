import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/widgets/cards/app_cards.dart';
import 'package:eda_restaurant/shared/data/demo_data.dart';
import 'package:eda_restaurant/shared/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;
  String _type = 'all';

  @override
  void initState() {
    super.initState();
    _notifications = List<AppNotification>.of(DemoData.notifications);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _type == 'all'
        ? _notifications
        : _notifications.where((item) => item.type == _type).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _notifications = [
                for (final item in _notifications) item.copyWith(read: true),
              ];
            }),
            child: const Text('Read all'),
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
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final type in ['all', 'menu', 'documents', 'insight'])
                ChoiceChip(
                  label: Text(type == 'insight' ? 'promotions' : type),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final item in visible)
            _NotificationTile(
              notification: item,
              onTap: () => setState(() {
                _notifications = [
                  for (final current in _notifications)
                    if (current.id == item.id)
                      current.copyWith(read: true)
                    else
                      current,
                ];
              }),
            ),
        ].animate(interval: 45.ms).fadeIn().slideY(begin: 0.03),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = notification.read ? AppColors.textMuted : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: color.withValues(alpha: 0.26)),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                notification.read
                    ? Icons.mark_email_read_rounded
                    : Icons.mark_email_unread_rounded,
                color: color,
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
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusBadge(
                          label: notification.read ? 'Read' : 'Unread',
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(notification.body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
