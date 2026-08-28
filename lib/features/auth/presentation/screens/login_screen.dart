import 'package:eda_restaurant/core/network/api_client.dart';
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
                    hint: 'Password',
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
                  Text(
                    'Partner accounts are created by admin only.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await ref.read(apiClientProvider).post<Map<String, dynamic>>(
        '/auth/partner/login',
        data: {'phone': phone, 'password': password},
      );
      final data = response.data;
      final token = data?['accessToken'] as String?;

      if (!mounted) return;
      if (token == null) {
        setState(() => _loading = false);
        ToastScope.of(context).error(
          'Could not sign in',
          subtitle: 'Check phone and password.',
        );
        return;
      }

      await persistAuth(
        ref,
        token: token,
        phone: phone,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ToastScope.of(context).success(
        'Signed in',
        subtitle: 'Partner dashboard is ready.',
      );
      context.go('/dashboard');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ToastScope.of(context).error(
        'Could not sign in',
        subtitle: 'Check API URL and credentials.',
      );
    }
  }
}
