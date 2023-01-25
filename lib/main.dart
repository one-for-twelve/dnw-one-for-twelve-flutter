import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:one_for_twelve/logging.dart';
import 'package:one_for_twelve/models/question_selection_strategies.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '../app_config.dart';
import '../services/ads.dart';
import '../services/languages.dart';
import '../services/game_service.dart';

import './firebase_options.dart';
import './app_localizations.dart';
import './settings_provider.dart';

import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/home_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.init();

  initLogging();

  if (AppConfig.instance.ignoreInvalidCertificates) {
    HttpOverrides.global = MyHttpOverrides();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tryWakeUpBackendWithoutBlocking();

  Ads.initialize();

  final window = WidgetsBinding.instance.window;

  await SettingsProvider.loadPreferences(window.locale.languageCode);

  final settingsProvider = SettingsProvider();
  settingsProvider.setPlatformBrightness(window.platformBrightness);

  window.onPlatformBrightnessChanged = () {
    settingsProvider.setPlatformBrightness(window.platformBrightness);
  };

  window.onLocaleChanged = () {
    settingsProvider.setLanguageCode(window.locale.languageCode,
        saveInPrefs: false);
  };

  runApp(MyApp(settingsProvider));
}

void tryWakeUpBackendWithoutBlocking() {
  try {
    GameService.create(Languages.dutch, QuestionSelectionStrategies.Random,
        ignoreIfAuthTokenIsMissing: true);
  } catch (e) {
    Log.instance.i(e.toString());
  }
}

class MyApp extends StatefulWidget {
  final SettingsProvider _settingsProvider;

  const MyApp(this._settingsProvider, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SettingsProvider get _settingsProvider => widget._settingsProvider;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildHomeScreen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        return snapshot.hasData ? const HomeScreen() : AuthScreen(null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) {
            return _settingsProvider;
          },
        )
      ],
      child: Consumer<SettingsProvider>(
        builder: (BuildContext ctx, SettingsProvider settings, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(settings.LanguageCode),
            supportedLocales: Languages.getSupportedLanguageCodes()
                .map((languageCode) => Locale(languageCode)),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData.from(
              colorScheme: const ColorScheme.dark(),
            ).copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // foreground
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: settings.themeMode,
            onGenerateRoute: (routeSettings) {
              if (routeSettings.name == "/home") {
                return PageRouteBuilder(
                  pageBuilder: (_, a1, a2) => _buildHomeScreen(),
                );
              }

              return null;
            },
            home: _buildHomeScreen(),
          );
        },
      ),
    );
  }
}
