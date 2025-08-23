import 'package:flutter/material.dart';
import 'package:library_app/pages/kitaplar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Kitap Uygulaması'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Kitaplar"),
            Tab(text: "Alınacak listesi"),
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
                "Menü",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text("Kitaplar"),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Alınacak Listesi"),
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
