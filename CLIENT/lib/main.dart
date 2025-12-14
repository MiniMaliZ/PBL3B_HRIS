import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:pbl3b_hris/features/schedule/localizations/locale_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocaleSetup.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      localizationsDelegates: LocaleSetup.delegates,
      supportedLocales: LocaleSetup.supportedLocales,
      locale: LocaleSetup.defaultLocale,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    );
  }
}
