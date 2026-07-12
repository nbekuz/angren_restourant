import 'dart:io';

import 'package:eda_restaurant/app.dart';
import 'package:eda_restaurant/core/constants/app_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('eda_restaurant_test_');
    Hive.init(hiveDir.path);
    await Hive.openBox<dynamic>(AppConstants.hiveBoxSettings);
    await Hive.openBox<dynamic>(AppConstants.hiveBoxCache);
    await Hive.openBox<dynamic>(AppConstants.hiveBoxSession);
  });

  tearDown(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  testWidgets('renders restaurant app splash', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EdaRestaurantApp()));

    expect(find.text(AppConstants.appName), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
