import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:eda_restaurant/core/router/app_router.dart';
import 'package:eda_restaurant/core/theme/app_theme.dart';
import 'package:eda_restaurant/core/toast/toast.dart';
import 'package:eda_restaurant/l10n/app_localizations.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EdaRestaurantApp extends ConsumerStatefulWidget {
  const EdaRestaurantApp({super.key});

  @override
  ConsumerState<EdaRestaurantApp> createState() => _EdaRestaurantAppState();
}

class _EdaRestaurantAppState extends ConsumerState<EdaRestaurantApp> {
  final ToastController _toastController = ToastController();

  @override
  void dispose() {
    _toastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ToastScope(
      controller: _toastController,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
        builder: (context, child) {
          return ToastOverlay(
            controller: _toastController,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
