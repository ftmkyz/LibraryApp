// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:library_app/pages/homepage.dart';
import 'package:google_fonts/google_fonts.dart';

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
  luna,
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
            onPrimary: Color.fromARGB(255, 145, 133, 133),
            secondary: Color.fromARGB(255, 45, 150, 236),
            onSecondary: Colors.white,
            surface: Color.fromARGB(255, 3, 26, 51),
            onSurface: Color.fromARGB(255, 221, 228, 233),
            background: Color.fromARGB(255, 29, 53, 91),
            onBackground: Colors.white,
            error: Color.fromARGB(208, 8, 231, 231),
            onError: Colors.white,
          ),
        );

      case AppTheme.luna:
        return ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          // textTheme: GoogleFonts.montserratTextTheme(),
          // textTheme: GoogleFonts.robotoTextTheme(),
          // textTheme: GoogleFonts.nunitoTextTheme(),
          // textTheme: GoogleFonts.openSansTextTheme(),
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Color(0xFF011C40),
            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 44, 130, 184),
            onSecondary: Colors.white,
            surface: Color.fromARGB(255, 49, 86, 129),
            onSurface: Color(0xFFE0F7FA),
            background: Color.fromARGB(255, 37, 60, 98),
            onBackground: Colors.white,
            error: Color.fromARGB(255, 4, 38, 82),
            onError: Colors.white,
          ),
        );

      case AppTheme.sunset: // 🌅 turuncu-kırmızı tonlu özel tema
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            surface: Color(0xFFFAE36F), // background surface rengi
            onSurface: Color(0xFFD6A10E), // surface üzerindeki metin rengi
            primary: Color(0xFFFBBA4B), // tab bar ve oran rengi
            error: Color(0xFF502503), // tab default ve hata rengi
            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 75, 46, 2),
            onSecondary: Colors.black,
            background: Color.fromARGB(255, 222, 178, 32),
            onBackground: Colors.black,
            onError: Colors.white,
          ),
        );

      case AppTheme.olive: // 🌿 yeşil pastel ton
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            surface: Color(0xFF27301B), // background surface rengi
            onSurface: Color(0xFFD8DDA8), // surface üzerindeki metin rengi
            primary: Color(0xFF99A558), // tab bar ve oran rengi
            error: Color(0xFF41521E), // tab default ve hata rengi
            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 75, 46, 2),
            onSecondary: Colors.black,
            background: Color.fromARGB(255, 222, 178, 32),
            onBackground: Colors.black,
            onError: Colors.white,
          ),
        );

      case AppTheme.light:
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        error: Color.fromARGB(255, 215, 137, 95),
        onError: Colors.white,
      ),
    );
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
