import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.scale = 0.96,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double scale;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppDurations.fast,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      onPressed: onPressed,
      foreground: Colors.white,
      gradient: AppColors.primaryGradient,
      shadow: AppShadows.button,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _BaseButton(
      label: label,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      onPressed: onPressed,
      foreground: isDark ? AppColors.darkTextPrimary : AppColors.secondary,
      background: isDark ? AppColors.darkSurface : AppColors.surface,
      borderColor: isDark ? AppColors.darkBorder : AppColors.border,
    );
  }
}

class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return _BaseButton(
      label: label,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      onPressed: onPressed,
      foreground: Colors.white,
      background: AppColors.error,
      shadow: [
        BoxShadow(
          color: AppColors.error.withValues(alpha: 0.22),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _BaseButton extends StatelessWidget {
  const _BaseButton({
    required this.label,
    required this.foreground,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
    this.icon,
    this.background,
    this.gradient,
    this.borderColor,
    this.shadow,
  });

  final String label;
  final Color foreground;
  final Color? background;
  final Gradient? gradient;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading && onPressed != null;
    return AnimatedButton(
      onPressed: enabled ? onPressed! : () {},
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.48,
        duration: AppDurations.fast,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: gradient == null ? background : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
            boxShadow: enabled ? shadow : null,
          ),
          child: Center(
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.color,
    this.icon,
  });

  final String label;
  final bool isLoading;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.6, color: color),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 21),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
