import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:eda_restaurant/core/theme/app_colors.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/core/widgets/buttons/app_buttons.dart';
import 'package:eda_restaurant/core/widgets/inputs/app_inputs.dart';
import 'package:eda_restaurant/core/widgets/states/app_states.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsProvider);
    _rememberMe = prefs.rememberMe;
    _phoneController.text = prefs.userPhone ?? '+998 90 777 22 11';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      message: 'Signing in',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: AppShadows.button,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ).animate().scale(
                    duration: 450.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign in to manage orders, menu availability, revenue, and restaurant status.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  PhoneField(
                    controller: _phoneController,
                    label: 'Phone number',
                    validator: (value) =>
                        value == null || value.trim().length < 7
                        ? 'Enter a valid phone number'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PasswordField(
                    controller: _passwordController,
                    hint: 'Demo password: 1234',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter password'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Switch.adaptive(
                        value: _rememberMe,
                        activeThumbColor: AppColors.primary,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Remember me',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ToastScope.of(context).info(
                            'Password recovery',
                            subtitle:
                                'Demo mode: ask your Eda manager to reset access.',
                          );
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Login',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: _loading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: 'Use demo password 1234',
                    icon: Icons.key_rounded,
                    onPressed: () {
                      _passwordController.text = '1234';
                      _login();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Demo login accepts password 1234, or any password with a phone number.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.035, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_loading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future<void>.delayed(550.ms);

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final valid =
        phone.isNotEmpty && (password == '1234' || password.isNotEmpty);

    if (!mounted) return;
    if (!valid) {
      setState(() => _loading = false);
      ToastScope.of(context).error(
        'Could not sign in',
        subtitle: 'Use a phone number and demo password 1234.',
      );
      return;
    }

    await persistAuth(
      ref,
      token: 'demo_restaurant_token_${DateTime.now().millisecondsSinceEpoch}',
      phone: phone,
      rememberMe: _rememberMe,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    ToastScope.of(context).success(
      'Signed in',
      subtitle: '${AppConstants.appName} is ready for service.',
    );
    context.go('/dashboard');
  }
}
