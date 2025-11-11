import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/provider/sync-provider.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/repository/all.additional.data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/provider/all.additional.data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/data/local/auth_repositoy.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/data/repository/farm_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/presentation/provider/farm_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/repository/livestock_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/presentation/provider/livestock_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/data/repository/log_additional_data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/data/repository/events_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/data/repository/vaccines_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/presentation/provider/vaccine_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_tag_and_seal_flutter_app/theme/theme_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/boarding/presentation/splash_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final database = AppDatabase();
  
  final additionalDataRepo = AllAdditionalDataRepository(database);
  final farmRepo = FarmRepository(database);
  final livestockRepo = LivestockRepository(database);
  final logAdditionalDataRepo = LogAdditionalDataRepository(database);
  final eventsRepo = EventsRepository(database);
  final vaccinesRepo = VaccinesRepository(database);
  
  // Initialize providers with SharedPreferences
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  final additionalDataProvider = AdditionalDataProvider(additionalDataRepository: additionalDataRepo);
  final authRepo = AuthRepository();
  final authProvider = AuthProvider(authRepository: authRepo, repository: authRepo);
  final syncProvider = SyncProvider(database: database);
  final farmProvider = FarmProvider(farmRepository: farmRepo);
  final livestockProvider = LivestockProvider(livestockRepo: livestockRepo);
  final logAdditionalDataProvider =
      LogAdditionalDataProvider(repository: logAdditionalDataRepo);
  final eventsProvider = EventsProvider(eventsRepository: eventsRepo);
  final vaccineProvider = VaccineProvider(vaccinesRepository: vaccinesRepo);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: additionalDataProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: syncProvider),
        ChangeNotifierProvider.value(value: farmProvider),
        ChangeNotifierProvider.value(value: livestockProvider),
        ChangeNotifierProvider.value(value: logAdditionalDataProvider),
        ChangeNotifierProvider.value(value: eventsProvider),
        ChangeNotifierProvider.value(value: vaccineProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // Method to change locale from anywhere in the app
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    if (state != null) {
      await state.changeLocale(newLocale);
    }
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  // Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('app_language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  // Change locale and save to SharedPreferences
  Future<void> changeLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', newLocale.languageCode);
    
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Tag & Seal',
      debugShowCheckedModeBanner: false,
      
      // Theme (persisted with SharedPreferences)
      theme: themeProvider.themeData,
      
      // Locale (persisted with SharedPreferences)
      locale: _locale,
      
      // Localization with Flutter l10n
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('sw'), // Swahili
      ],
      
      // Initial route
      home: const SplashScreen(),
    );
  }
}
