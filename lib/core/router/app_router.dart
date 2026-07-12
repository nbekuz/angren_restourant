import 'package:eda_restaurant/core/router/page_transitions.dart';
import 'package:eda_restaurant/core/widgets/navigation/merchant_shell.dart';
import 'package:eda_restaurant/features/auth/presentation/screens/login_screen.dart';
import 'package:eda_restaurant/features/documents/presentation/screens/documents_screen.dart';
import 'package:eda_restaurant/features/language/presentation/screens/language_screen.dart';
import 'package:eda_restaurant/features/menu/presentation/screens/category_manage_screen.dart';
import 'package:eda_restaurant/features/menu/presentation/screens/menu_screen.dart';
import 'package:eda_restaurant/features/menu/presentation/screens/product_edit_screen.dart';
import 'package:eda_restaurant/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:eda_restaurant/features/orders/presentation/screens/order_details_screen.dart';
import 'package:eda_restaurant/features/orders/presentation/screens/orders_screen.dart';
import 'package:eda_restaurant/features/profile/presentation/screens/profile_screen.dart';
import 'package:eda_restaurant/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:eda_restaurant/features/settings/presentation/screens/settings_screen.dart';
import 'package:eda_restaurant/features/splash/presentation/screens/splash_screen.dart';
import 'package:eda_restaurant/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/language',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const LanguageScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const LoginScreen()),
      ),
      GoRoute(path: '/dashboard', redirect: (context, state) => '/orders'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MerchantShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                pageBuilder: (context, state) =>
                    fadeSlidePage(state: state, child: const OrdersScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                pageBuilder: (context, state) =>
                    fadeSlidePage(state: state, child: const MenuScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                pageBuilder: (context, state) =>
                    fadeSlidePage(state: state, child: const ScheduleScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                pageBuilder: (context, state) => fadeSlidePage(
                  state: state,
                  child: const StatisticsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    fadeSlidePage(state: state, child: const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/orders/:id',
        pageBuilder: (context, state) => fadeSlidePage(
          state: state,
          child: OrderDetailsScreen(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/menu/product/new',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const ProductEditScreen()),
      ),
      GoRoute(
        path: '/menu/product/:id',
        pageBuilder: (context, state) => fadeSlidePage(
          state: state,
          child: ProductEditScreen(productId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/menu/category',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const CategoryManageScreen()),
      ),
      GoRoute(
        path: '/documents',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const DocumentsScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const NotificationsScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            fadeSlidePage(state: state, child: const SettingsScreen()),
      ),
    ],
  );
});
