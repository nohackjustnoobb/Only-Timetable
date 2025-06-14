import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:only_timetable/services/appearance_service.dart';
import 'package:provider/provider.dart';

import 'package:only_timetable/globals.dart';
import 'package:only_timetable/services/main_service.dart';
import 'package:only_timetable/screens/home.dart';
import 'l10n/app_localizations.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final mainService = MainService();
  await mainService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: mainService),
        ChangeNotifierProvider.value(value: mainService.pluginService),
        ChangeNotifierProvider.value(value: mainService.settingsService),
        ChangeNotifierProvider.value(value: mainService.etaService),
        ChangeNotifierProvider.value(value: mainService.bookmarkService),
        ChangeNotifierProvider.value(value: mainService.appearanceService),
        ChangeNotifierProvider.value(value: mainService.nearbyService),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceService>(
      builder: (context, appearanceService, child) => MaterialApp(
        title: "Only Timetable",
        themeMode: appearanceService.themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            surface: Colors.grey[200]!,
            surfaceContainer: Colors.white,
            shadow: Colors.grey[350]!,
            primary: appearanceService.primaryColor,
          ),
          textTheme: TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w300),
            titleMedium: TextStyle(fontWeight: FontWeight.w300),
            titleSmall: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            surface: Colors.grey[900]!,
            shadow: Colors.grey[850]!,
            surfaceContainer: Colors.grey[850]!,
            primary: appearanceService.primaryColor,
          ),
          textTheme: TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.w300),
            titleMedium: TextStyle(fontWeight: FontWeight.w300),
            titleSmall: TextStyle(fontWeight: FontWeight.w300),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: appearanceService.locale,
        navigatorKey: navigatorKey,
        home: const HomeScreen(),
      ),
    );
  }
}
