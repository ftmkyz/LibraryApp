import 'package:flutter/material.dart';
import 'package:library_app/pages/kitaplar.dart';
import 'package:library_app/pages/wishlist.dart';
import 'package:library_app/pages/edit_profile.dart';

class HomePage extends StatefulWidget {
  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChange;
  final bool isDarkTheme;
  final ValueChanged<bool>? onThemeToggle;
  const HomePage({
    super.key,
    this.locale,
    this.onLocaleChange,
    this.isDarkTheme = false,
    this.onThemeToggle,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isTurkish ? 'Kitaplarım' : 'My Books'),
        actions: [
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
                value: Locale('en'),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'English',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: Locale('tr'),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Türkçe',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              widget.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            tooltip: widget.isDarkTheme
                ? (isTurkish ? 'Açık Tema' : 'Light Theme')
                : (isTurkish ? 'Koyu Tema' : 'Dark Theme'),
            onPressed: () {
              if (widget.onThemeToggle != null) {
                widget.onThemeToggle!(!widget.isDarkTheme);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isTurkish ? "Kitaplar" : "Books"),
            Tab(text: isTurkish ? "Alınacak listesi" : "Wishlist"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.blue[100],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                    backgroundColor: Colors.transparent,
                    onBackgroundImageError:
                        (_, __) {}, // If image not found, show empty avatar
                    child: null, // No child, so empty if image not found
                  ),
                  SizedBox(height: 12),
                  Text(
                    isTurkish ? "Menü" : "Menu",
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(isTurkish ? "Kitaplar" : "Books"),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(isTurkish ? "Alınacak listesi" : "Wishlist"),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(isTurkish ? "Profili Düzenle" : "Edit Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KitaplarSayfasi(),
          WishlistPage(locale: widget.locale),
        ],
      ),
    );
  }
}
