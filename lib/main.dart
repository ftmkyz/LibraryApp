// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:library_app/pages/homepage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

// Tema seçenekleri
enum AppTheme { light, dark, luna, sunset, olive, pinkgray, red, chocalate }

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr');
  AppTheme _currentTheme = AppTheme.light;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // uygulama açıldığında tema ve dili yükle
  }

  // SharedPreferences'tan tema ve dil yükleme
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Tema yükleme
    final savedTheme = prefs.getString('selectedTheme');
    if (savedTheme != null) {
      setState(() {
        _currentTheme = AppTheme.values.firstWhere(
          (t) => t.toString() == savedTheme,
          orElse: () => AppTheme.light,
        );
      });
    }

    // Dil yükleme
    final savedLang = prefs.getString('selectedLanguage');
    if (savedLang != null) {
      setState(() {
        _locale = Locale(savedLang);
      });
    }
  }

  // Tema değişince kaydet
  Future<void> _saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', theme.toString());
  }

  // Dil değişince kaydet
  Future<void> _saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', locale.languageCode);
  }

  // Tema değiştir
  void _changeTheme(AppTheme theme) {
    setState(() {
      _currentTheme = theme;
    });
    _saveTheme(theme);
  }

  // Dil değiştir
  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    _saveLanguage(locale);
  }

  // Tema seçimine göre ThemeData döndür
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
          textTheme: GoogleFonts.poppinsTextTheme(),
        );
      case AppTheme.pinkgray:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.light,
            surface: Color(0xFF2A3843),
            onSurface: Color(0xFFFF096C),
            error: Color(0xFF4F6172),
            primary: Color(0xFF192731),

            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 75, 46, 2),
            onSecondary: Colors.black,
            background: Color.fromARGB(255, 222, 178, 32),
            onBackground: Colors.black,
            onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );

      case AppTheme.red:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.light,
            onSurface: Color(0xFF680C0A),
            surface: Color(0xFFBE320F),
            error: Color(0xFFCC5B4A),
            primary: Color(0xFFEBa9A6),

            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 75, 46, 2),
            onSecondary: Colors.black,
            background: Color.fromARGB(255, 222, 178, 32),
            onBackground: Colors.black,
            onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );
      case AppTheme.chocalate:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.light,
            onSurface: Color(0xFFB7603A),
            surface: Color(0xFF26140C),
            error: Color(0xFF492617),
            primary: Color(0xFF713B24),

            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 214, 212, 208),
            onSecondary: Color.fromARGB(255, 236, 232, 232),
            background: Color.fromARGB(255, 222, 178, 32),
            onBackground: Color.fromARGB(255, 255, 248, 248),
            onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );
      case AppTheme.luna:
        return ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
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

      case AppTheme.sunset:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            surface: Color(0xFFFAE36F),
            onSurface: Color(0xFFD6A10E),
            primary: Color(0xFFFBBA4B),
            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 75, 46, 2),
            onSecondary: Colors.black,
            background: Color.fromARGB(255, 222, 178, 32),
            onBackground: Colors.black,
            error: Color(0xFF502503),
            onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );

      case AppTheme.olive:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            surface: Color(0xFF27301B),
            onSurface: Color(0xFFD8DDA8),
            primary: Color(0xFF99A558),
            onPrimary: Colors.white,
            secondary: Color.fromARGB(255, 75, 46, 2),
            onSecondary: Colors.black,
            background: Color.fromARGB(255, 222, 178, 32),
            onBackground: Colors.black,
            error: Color(0xFF41521E),
            onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );

      case AppTheme.light:
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        error: Color.fromARGB(255, 4, 44, 112),
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
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
