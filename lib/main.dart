import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/connection_provider.dart';
import 'providers/recording_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/translation_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const HarmonyApp());
}

class HarmonyApp extends StatelessWidget {
  const HarmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProxyProvider<ConnectionProvider, RecordingProvider>(
          create: (ctx) => RecordingProvider(ctx.read<ConnectionProvider>()),
          update: (_, __, prev) => prev!,
        ),
        ChangeNotifierProxyProvider<ConnectionProvider, TranslationProvider>(
          create: (ctx) => TranslationProvider(ctx.read<ConnectionProvider>()),
          update: (_, __, prev) => prev!,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProv, __) {
          return MaterialApp(
            title: 'Harmony',
            debugShowCheckedModeBanner: false,
            theme: themeProv.themeData,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
