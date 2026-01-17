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
enum AppTheme { dark, luna, sunset, olive, pinkgray, red, chocalate }

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr');
  AppTheme _currentTheme = AppTheme.dark;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // uygulama açıldığında tema ve dili yükle
  }

  // SharedPreferences'tan tema ve dil yükleme
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Tema yükleme (index ile)
    final savedThemeIndex = prefs.getInt('selectedThemeIndex');
    if (savedThemeIndex != null) {
      setState(() {
        _currentTheme = AppTheme.values[savedThemeIndex];
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
    await prefs.setInt('selectedThemeIndex', theme.index);
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
            surface: Color.fromARGB(255, 26, 23, 23), // arka plan
            primary: Color(0xFFFFFCD0), // highlight()
            onPrimary: Color.fromARGB(255, 26, 23, 23), //checkbox
            // secondary: Color(0xFF403D3E), //card tamamlandı
            tertiary: Color(0xFF403D3E), //card tamamlandı bakckground,
            tertiaryFixed: Color.fromARGB(
              255,
              144,
              131,
              136,
            ), //card tamamlandı bakckground,
            background: Color(0xFF807e83), //card tamamlanmadı bakckground,
            onBackground: Color.fromARGB(
              255,
              202,
              199,
              206,
            ), //card tamamlanmadı bakckground,
            error: Color.fromARGB(255, 196, 189, 192),
            // onSecondary: Colors.white,
            onSurface: Color.fromARGB(255, 221, 228, 233), //textcolor
            // onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );
      case AppTheme.pinkgray:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.light,
            surface: Color(0xFF4F6172), // arka plan
            primary: Color(0xFFFF096C), // highlight()
            onPrimary: Color.fromARGB(255, 98, 3, 41), //checkbox
            tertiary: Color(0xFF403D3E), //card tamamlandı bakckground,
            tertiaryFixed: Color(0xFF192731), //card tamamlandı bakckground,
            background: Color(0xFFff096C), //card tamamlanmadı bakckground,
            onBackground: Color(0xFF2A3843), //card tamamlanmadı bakckground,
            error: Color.fromARGB(255, 196, 189, 192),
            onSurface: Color.fromARGB(255, 221, 228, 233),
            // surface: Color(0xFF2A3843),
            // onSurface: Color(0xFFFF096C),
            // error: Color.fromARGB(255, 114, 79, 96),
            // primary: Color(0xFF192731),
            // tertiary: Color.fromARGB(255, 82, 26, 48),
            // tertiaryFixed: Color.fromARGB(255, 228, 69, 132),
            // onPrimary: Colors.white,
            // secondary: Color.fromARGB(255, 75, 46, 2),
            // onSecondary: Colors.black,
            // background: Color.fromARGB(255, 222, 178, 32),
            // onBackground: Colors.black,
            // onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );

      case AppTheme.red:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.light,
            surface: Color(0xFF680C0A), // arka plan
            primary: Color(0xFFEBA9A6), // highlight()
            onPrimary: Color.fromARGB(255, 98, 3, 41), //checkbox
            tertiary: Color(0xFF1B0404), //card tamamlandı bakckground,
            tertiaryFixed: Color.fromARGB(
              255,
              125,
              19,
              19,
            ), //card tamamlandı bakckground,
            background: Color(0xFFBe320F), //card tamamlanmadı bakckground,
            onBackground: Color.fromARGB(
              255,
              229,
              61,
              20,
            ), //card tamamlanmadı bakckground,
            error: Color.fromARGB(255, 196, 189, 192),
            onSurface: Color.fromARGB(255, 221, 228, 233),
            // onSurface: Color.fromARGB(255, 215, 198, 212), //text color
            // surface: Color(0xFF974A45), //background of cards
            // error: Color(0xFF871A1D), //
            // primary: Color(0xFFD76762), //main color
            // tertiary: Color.fromARGB(255, 46, 9, 10), //okundu
            // tertiaryFixed: Color.fromARGB(255, 219, 41, 47),
            // onPrimary: Colors.white,
            // secondary: Color.fromARGB(255, 75, 46, 2),
            // onSecondary: Colors.black,
            // background: Color.fromARGB(255, 222, 178, 32),
            // onBackground: Colors.black,
            // onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );
      case AppTheme.chocalate:
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.light,
            surface: Color(0xFF944E2F), // arka plan
            primary: Color(0xFFB7603A), // highlight()
            onPrimary: Color.fromARGB(255, 98, 3, 41), //checkbox
            tertiary: Color(0xFF26140C), //card tamamlandı bakckground,
            tertiaryFixed: Color.fromARGB(
              255,
              114,
              60,
              36,
            ), //card tamamlandı bakckground,
            background: Color(0xFFb7603a), //card tamamlanmadı bakckground,
            onBackground: Color.fromARGB(
              255,
              229,
              119,
              72,
            ), //card tamamlanmadı bakckground,
            error: Color.fromARGB(255, 196, 189, 192),
            onSurface: Color.fromARGB(255, 221, 228, 233),
            // onSurface: Color(0xFFB7603A),
            // surface: Color(0xFF26140C),
            // error: Color(0xFF492617),
            // primary: Color(0xFF713B24),
            // tertiary: Color.fromARGB(255, 35, 13, 3),
            // tertiaryFixed: Color.fromARGB(255, 194, 72, 16),
            // onPrimary: Colors.white,
            // secondary: Color.fromARGB(255, 214, 212, 208),
            // onSecondary: Color.fromARGB(255, 236, 232, 232),
            // background: Color.fromARGB(255, 222, 178, 32),
            // onBackground: Color.fromARGB(255, 255, 248, 248),
            // onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );
      case AppTheme.luna:
        return ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            surface: Color(0xFF26658C), // arka plan
            primary: Color(0xFFA7EBF2), // highlight()
            onPrimary: Color.fromARGB(255, 98, 3, 41), //checkbox
            tertiary: Color(0xFF011C40), //card tamamlandı bakckground,
            tertiaryFixed: Color.fromARGB(
              255,
              1,
              84,
              192,
            ), //card tamamlandı bakckground,
            background: Color(0xFF57acbf), //card tamamlanmadı bakckground,
            onBackground: Color.fromARGB(
              255,
              112,
              224,
              249,
            ), //card tamamlanmadı bakckground,
            error: Color.fromARGB(255, 196, 189, 192),
            onSurface: Color.fromARGB(255, 221, 228, 233),

            secondary: Color.fromARGB(255, 44, 130, 184),
            onSecondary: Colors.white,
            onError: Colors.white,
            // primary: Color(0xFF011C40),
            // onPrimary: Colors.white,
            // secondary: Color.fromARGB(255, 44, 130, 184),
            // onSecondary: Colors.white,
            // surface: Color.fromARGB(255, 49, 86, 129),
            // tertiary: Color.fromARGB(255, 10, 33, 61),
            // tertiaryFixed: Color.fromARGB(255, 31, 106, 197),
            // onSurface: Color(0xFFE0F7FA),
            // background: Color.fromARGB(255, 37, 60, 98),
            // onBackground: Colors.white,
            // error: Color.fromARGB(255, 4, 38, 82),
            // onError: Colors.white,
          ),
        );

      case AppTheme.sunset:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            surface: Color(0xFFd6a10e), // arka plan
            primary: Color.fromARGB(255, 227, 183, 10), // highlight()
            onPrimary: Color.fromARGB(255, 98, 3, 41), //checkbox
            tertiary: Color.fromARGB(
              255,
              207,
              122,
              37,
            ), //card tamamlandı bakckground,
            tertiaryFixed: Color.fromARGB(
              255,
              190,
              97,
              4,
            ), //card tamamlandı bakckground,
            background: Color.fromARGB(
              255,
              238,
              195,
              8,
            ), //card tamamlanmadı bakckground,
            onBackground: Color.fromARGB(
              255,
              221,
              187,
              32,
            ), //card tamamlanmadı bakckground,
            error: Color.fromARGB(255, 196, 189, 192),
            onSurface: Color.fromARGB(255, 221, 228, 233),

            secondary: Color.fromARGB(255, 44, 130, 184),
            onSecondary: Colors.white,
            onError: Colors.white,
            // surface: Color.fromARGB(255, 242, 207, 29),
            // onSurface: Color.fromARGB(255, 96, 44, 4),
            // tertiary: Color.fromARGB(255, 201, 130, 9),
            // tertiaryFixed: Color.fromARGB(255, 243, 171, 47),
            // primary: Color(0xFF773D02),
            // onPrimary: Colors.white,
            // secondary: Color.fromARGB(255, 75, 46, 2),
            // onSecondary: Colors.black,
            // background: Color.fromARGB(255, 222, 178, 32),
            // onBackground: Colors.black,
            // error: Color(0xFF502503),
            // onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );

      case AppTheme.olive:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            surface: Color(0xFF676936), // arka plan
            primary: Color.fromARGB(255, 140, 167, 3), // highlight()
            onPrimary: Color.fromARGB(255, 98, 3, 41), //checkbox
            tertiary: Color.fromARGB(
              255,
              161,
              165,
              41,
            ), //card tamamlandı bakckground,
            tertiaryFixed: Color.fromARGB(
              255,
              118,
              121,
              30,
            ), //card tamamlandı bakckground,
            background: Color.fromARGB(
              255,
              220,
              227,
              16,
            ), //card tamamlanmadı bakckground,
            onBackground: Color.fromARGB(
              255,
              153,
              158,
              14,
            ), //card tamamlanmadı bakckground,
            error: Color.fromARGB(255, 196, 189, 192),
            onSurface: Color.fromARGB(255, 221, 228, 233),

            secondary: Color.fromARGB(255, 44, 130, 184),
            onSecondary: Colors.white,
            onError: Colors.white,
            // surface: Color(0xFF27301B),
            // tertiary: Color(0xFF41521E),
            // tertiaryFixed: Color.fromARGB(255, 173, 219, 81),
            // onSurface: Color(0xFFD8DDA8),
            // primary: Color.fromARGB(255, 68, 174, 60),
            // onPrimary: Colors.white,
            // secondary: Color.fromARGB(255, 75, 46, 2),
            // onSecondary: Colors.black,
            // background: Color.fromARGB(255, 222, 178, 32),
            // onBackground: Colors.black,
            // error: Color(0xFF41521E),
            // onError: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );

      // case AppTheme.light:
    }
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
