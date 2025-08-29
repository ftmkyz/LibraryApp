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

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr');
  bool _isDarkTheme = false;

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitaplarım',
      theme: ThemeData(
        brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
      ),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(
        locale: _locale,
        onLocaleChange: _changeLanguage,
        isDarkTheme: _isDarkTheme,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}
