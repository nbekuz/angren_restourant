import 'package:eda_restaurant/app.dart';
import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:eda_restaurant/core/network/api_client.dart';
import 'package:eda_restaurant/core/services/messaging_service.dart';
import 'package:eda_restaurant/shared/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(AppConstants.hiveBoxSettings);
  await Hive.openBox<dynamic>(AppConstants.hiveBoxCache);
  await Hive.openBox<dynamic>(AppConstants.hiveBoxSession);

  runApp(
    const ProviderScope(
      child: _Bootstrap(child: EdaRestaurantApp()),
    ),
  );
}

class _Bootstrap extends ConsumerStatefulWidget {
  const _Bootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<_Bootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final messaging = ref.read(messagingServiceProvider);
      final fcmToken = await messaging.initialize();
      final authToken = ref.read(authTokenProvider);
      if (authToken != null &&
          authToken.isNotEmpty &&
          fcmToken != null &&
          fcmToken.isNotEmpty) {
        await messaging.registerWithBackend(
          ref.read(apiClientProvider),
          token: fcmToken,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
