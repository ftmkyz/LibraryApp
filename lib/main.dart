// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:library_app/pages/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

enum AppTheme {
  light,
  dark,
  lavender, // 🌸 özel tema
  sunset, // 🌅 özel tema
  olive, // 🌿 özel tema
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr');
  AppTheme _currentTheme = AppTheme.light;

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _changeTheme(AppTheme theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  ThemeData _getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF90CAF9),
            secondary: Color(0xFFCE93D8),
            surface: Color(0xFF121212),
            background: Color(0xFF000000),
            onPrimary: Colors.white,
            onSurface: Colors.white,
          ),
        );

      case AppTheme.lavender: // 🌸 özel tema örneği
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFFB388EB),
            onPrimary: Colors.white,
            secondary: Color(0xFFF48FB1),
            onSecondary: Colors.white,
            surface: Color(0xFFF3E5F5),
            onSurface: Color(0xFF4A148C),
            background: Color(0xFFF8EAF6),
            onBackground: Colors.black,
            error: Colors.redAccent,
            onError: Colors.white,
          ),
        );

      case AppTheme.sunset: // 🌅 turuncu-kırmızı tonlu özel tema
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFFFF7043),
            onPrimary: Colors.white,
            secondary: Color(0xFFFFB74D),
            onSecondary: Colors.black,
            surface: Color(0xFFFFF3E0),
            onSurface: Colors.black87,
            background: Color(0xFFFFF8E1),
            onBackground: Colors.black,
            error: Colors.redAccent,
            onError: Colors.white,
          ),
        );

      case AppTheme.olive: // 🌿 yeşil pastel ton
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF8E9A5B),
            onPrimary: Colors.white,
            secondary: Color(0xFFDCE775),
            onSecondary: Colors.black,
            surface: Color(0xFFF9FBE7),
            onSurface: Color(0xFF33691E),
            background: Color(0xFFF1F8E9),
            onBackground: Colors.black,
            error: Colors.redAccent,
            onError: Colors.white,
          ),
        );

      case AppTheme.light:
    }
    return ThemeData.light();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitaplarım',
      debugShowCheckedModeBanner: false,
      theme: _getThemeData(_currentTheme),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(
        locale: _locale,
        onLocaleChange: _changeLanguage,
        currentTheme: _currentTheme,
        onThemeChange: _changeTheme,
      ),
    );
  }
}
