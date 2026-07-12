import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppDurations.splash, _route);
  }

  void _route() {
    if (!mounted) return;
    final languageSelected = ref.read(languageSelectedProvider);
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!languageSelected) {
      context.go('/language');
    } else if (isAuthenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white24),
                      boxShadow: AppShadows.glow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/app.png',
                      fit: BoxFit.cover,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.82, 0.82),
                    end: const Offset(1, 1),
                    duration: 650.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 450.ms),
              const SizedBox(height: AppSpacing.xl),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.18, end: 0),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Merchant operations, refined',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                ),
              ).animate().fadeIn(delay: 360.ms),
            ],
          ),
        ),
      ),
    );
  }
}
