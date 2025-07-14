import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_listing_app/core/app/bindings/app_bindings.dart';
import 'package:property_listing_app/core/app/routes/app_pages.dart';

import 'package:property_listing_app/core/app/themes/app_theme.dart';
import 'package:property_listing_app/core/helper/firebase_notification_web_listener.dart';
import 'package:property_listing_app/core/helper/firebase_web_service.dart';
import 'package:property_listing_app/firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  registerFirebaseServiceWorker();
  if (kIsWeb) {
    setupWebNotificationRouteListener();
  }
  await AppBindings().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Property Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
