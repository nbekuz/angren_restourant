import 'package:eda_restaurant/app.dart';
import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(AppConstants.hiveBoxSettings);
  await Hive.openBox<dynamic>(AppConstants.hiveBoxCache);
  await Hive.openBox<dynamic>(AppConstants.hiveBoxSession);

  runApp(const ProviderScope(child: EdaRestaurantApp()));
}
