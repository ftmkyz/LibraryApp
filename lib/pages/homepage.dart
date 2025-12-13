// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:library_app/pages/books.dart';
import 'package:library_app/pages/wishlist.dart';
import '../main.dart'; // AppTheme enum'unu alabilmek için

class HomePage extends StatefulWidget {
  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChange;
  final AppTheme currentTheme;
  final ValueChanged<AppTheme>? onThemeChange;

  const HomePage({
    super.key,
    this.locale,
    this.onLocaleChange,
    required this.currentTheme,
    this.onThemeChange,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isTurkish = widget.locale?.languageCode == 'tr';
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isTurkish ? 'Kitaplarım' : 'My Books'),
        actions: [
          /// Dil değiştirme menüsü
          DropdownButton<Locale>(
            value: widget.locale ?? const Locale('tr'),
            dropdownColor: Theme.of(context).canvasColor,
            underline: Container(),
            onChanged: (Locale? newLocale) {
              if (newLocale != null && widget.onLocaleChange != null) {
                widget.onLocaleChange!(newLocale);
              }
            },
            items: [
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text(
                  'English',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: const Locale('tr'),
                child: Text(
                  'Türkçe',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          /// Tema seçimi (carousel slider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 80,
              height: 60,
              child: ThemeCarousel(
                currentTheme: widget.currentTheme,
                onThemeChange: widget.onThemeChange,
              ),
            ),
          ),
        ],

        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: theme.colorScheme.error,
          tabs: [
            Tab(text: isTurkish ? "Kitaplığım" : "My Books"),
            Tab(text: isTurkish ? "Alınacak Listesi" : "Wishlist"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          const BooksPage(),
          WishlistPage(locale: widget.locale),
        ],
      ),
    );
  }
}

/// Carousel slider widget
class ThemeCarousel extends StatefulWidget {
  final AppTheme currentTheme;
  final ValueChanged<AppTheme>? onThemeChange;

  const ThemeCarousel({
    super.key,
    required this.currentTheme,
    this.onThemeChange,
  });

  @override
  State<ThemeCarousel> createState() => _ThemeCarouselState();
}

class _ThemeCarouselState extends State<ThemeCarousel> {
  late PageController _pageController;
  late int _currentIndex;

  final Map<AppTheme, Color> themeColors = {
    AppTheme.light: const Color.fromARGB(255, 184, 182, 175),
    AppTheme.dark: const Color.fromARGB(255, 67, 67, 69),
    AppTheme.luna: const Color.fromARGB(255, 91, 160, 240),
    AppTheme.sunset: const Color.fromARGB(225, 201, 170, 15),
    AppTheme.olive: const Color(0xFF99A558),
    AppTheme.pinkgray: const Color(0xFFFF096C),
    AppTheme.red: const Color(0xFF680C0A),
    AppTheme.chocalate: const Color(0xFFB7603A),
  };

  @override
  void initState() {
    super.initState();
    _currentIndex = AppTheme.values.indexOf(widget.currentTheme);
    // viewportFraction: 0.5 → bir tanesi tam, yanındakiler yarım görünecek
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      // sonsuz döngü için büyük bir itemCount veriyoruz
      itemCount: 10000,
      onPageChanged: (index) {
        final themeIndex = index % AppTheme.values.length;
        setState(() {
          _currentIndex = themeIndex;
        });
        widget.onThemeChange?.call(AppTheme.values[themeIndex]);
      },
      itemBuilder: (context, index) {
        final themeIndex = index % AppTheme.values.length;
        final theme = AppTheme.values[themeIndex];
        final color = themeColors[theme]!;
        final isSelected = themeIndex == _currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isSelected ? Icon(Icons.check, color: Colors.white) : null,
          ),
        );
      },
    );
  }
}
