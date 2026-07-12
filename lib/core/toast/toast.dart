import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

class ToastController extends ChangeNotifier {
  final Queue<_ToastEntry> _queue = Queue<_ToastEntry>();
  _ToastEntry? _current;
  Timer? _timer;

  void success(String title, {String? subtitle}) {
    show(type: ToastType.success, title: title, subtitle: subtitle);
  }

  void error(String title, {String? subtitle}) {
    show(type: ToastType.error, title: title, subtitle: subtitle);
  }

  void warning(String title, {String? subtitle}) {
    show(type: ToastType.warning, title: title, subtitle: subtitle);
  }

  void info(String title, {String? subtitle}) {
    show(type: ToastType.info, title: title, subtitle: subtitle);
  }

  void show({
    required ToastType type,
    required String title,
    String? subtitle,
    Duration duration = AppDurations.toast,
  }) {
    _queue.add(
      _ToastEntry(
        id: DateTime.now().microsecondsSinceEpoch,
        type: type,
        title: title,
        subtitle: subtitle,
        duration: duration,
      ),
    );
    if (_current == null) _showNext();
  }

  void dismiss() {
    _timer?.cancel();
    _timer = null;
    _current = null;
    notifyListeners();
    Future<void>.delayed(AppDurations.fast, _showNext);
  }

  void _showNext() {
    if (_current != null || _queue.isEmpty) return;
    _current = _queue.removeFirst();
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(_current!.duration, dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class ToastScope extends InheritedWidget {
  const ToastScope({super.key, required this.controller, required super.child});

  final ToastController controller;

  static ToastController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ToastScope>();
    assert(scope != null, 'ToastScope was not found above this context.');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(ToastScope oldWidget) {
    return oldWidget.controller != controller;
  }
}

class ToastOverlay extends StatefulWidget {
  const ToastOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  final ToastController controller;
  final Widget child;

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant ToastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onChanged);
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final toast = widget.controller._current;
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        widget.child,
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: MediaQuery.paddingOf(context).top + AppSpacing.md,
          child: IgnorePointer(
            ignoring: toast == null,
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.35),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: toast == null
                  ? const SizedBox.shrink()
                  : _ToastCard(
                      key: ValueKey(toast.id),
                      toast: toast,
                      onDismissed: widget.controller.dismiss,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({super.key, required this.toast, required this.onDismissed});

  final _ToastEntry toast;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final color = toast.type.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: ValueKey(toast.id),
      direction: DismissDirection.up,
      onDismissed: (_) => onDismissed(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGlass : AppColors.lightGlass,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: color.withValues(alpha: 0.36)),
              boxShadow: AppShadows.toast,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(toast.type.icon, color: color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toast.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (toast.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            toast.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onDismissed,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastEntry {
  const _ToastEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.duration,
    this.subtitle,
  });

  final int id;
  final ToastType type;
  final String title;
  final String? subtitle;
  final Duration duration;
}

extension on ToastType {
  Color get color => switch (this) {
    ToastType.success => AppColors.success,
    ToastType.error => AppColors.error,
    ToastType.info => AppColors.info,
    ToastType.warning => AppColors.warning,
  };

  IconData get icon => switch (this) {
    ToastType.success => Icons.check_circle_rounded,
    ToastType.error => Icons.error_rounded,
    ToastType.info => Icons.info_rounded,
    ToastType.warning => Icons.warning_rounded,
  };
}
