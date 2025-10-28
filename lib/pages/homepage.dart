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
                child: Row(
                  children: [
                    // const Icon(Icons.translate),
                    const SizedBox(width: 8),
                    Text(
                      'English',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: const Locale('tr'),
                child: Row(
                  children: [
                    // const Icon(Icons.translate),
                    const SizedBox(width: 8),
                    Text(
                      'Türkçe',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// Tema seçimi (renk temaları)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<AppTheme>(
              value: AppTheme.values.contains(widget.currentTheme)
                  ? widget.currentTheme
                  : AppTheme.light,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).canvasColor,
              // icon: const Icon(Icons.palette_outlined),
              onChanged: (AppTheme? newTheme) {
                if (newTheme != null && widget.onThemeChange != null) {
                  widget.onThemeChange!(newTheme);
                }
              },
              items: [
                DropdownMenuItem(
                  value: AppTheme.light,
                  child: Icon(
                    Icons.blur_on,
                    color: const Color.fromARGB(255, 184, 182, 175),
                  ),
                ),
                DropdownMenuItem(
                  value: AppTheme.dark,
                  child: Icon(
                    Icons.blur_on,
                    color: const Color.fromARGB(255, 67, 67, 69),
                  ),
                ),
                DropdownMenuItem(
                  value: AppTheme.luna,
                  child: Icon(
                    Icons.blur_on,
                    color: Color.fromARGB(255, 91, 160, 240),
                  ),
                ),
                DropdownMenuItem(
                  value: AppTheme.sunset,
                  child: Icon(
                    Icons.blur_on,
                    color: Color.fromARGB(255, 251, 210, 0),
                  ),
                ),
                DropdownMenuItem(
                  value: AppTheme.olive,
                  child: Icon(Icons.blur_on, color: Color(0xFF99A558)),
                ),
                DropdownMenuItem(
                  value: AppTheme.pinkgray,
                  child: Icon(Icons.blur_on, color: Color(0xFFFF096C)),
                ),
                DropdownMenuItem(
                  value: AppTheme.red,
                  child: Icon(Icons.blur_on, color: Color(0xFF680C0A)),
                ),
                DropdownMenuItem(
                  value: AppTheme.chocalate,
                  child: Icon(Icons.blur_on, color: Color(0xFFB7603A)),
                ),
              ],
            ),
          ),
        ],

        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onSurface, // seçili tab yazı rengi
          // ignore: deprecated_member_use
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
