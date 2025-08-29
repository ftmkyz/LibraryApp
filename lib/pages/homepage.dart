import 'package:flutter/material.dart';
import 'package:library_app/pages/kitaplar.dart';

class HomePage extends StatefulWidget {
  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChange;
  const HomePage({super.key, this.locale, this.onLocaleChange});
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
            icon: const Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.white,
            underline: Container(),
            onChanged: (Locale? newLocale) {
              if (newLocale != null && widget.onLocaleChange != null) {
                widget.onLocaleChange!(newLocale);
              }
            },
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('tr'), child: Text('Türkçe')),
            ],
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
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                isTurkish ? "Menü" : "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KitaplarSayfasi(),
          Center(child: Text("Burada farklı bir sayfa olacak")),
        ],
      ),
    );
  }
}
