import 'package:flutter/material.dart';
import 'package:library_app/widgets/textarea.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistPage extends StatefulWidget {
  final Locale? locale;
  final Function(Map<String, String>)? onMoveToBooks;
  const WishlistPage({super.key, this.locale, this.onMoveToBooks});
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _formKey = GlobalKey<FormState>();
  final _kitapAdiController = TextEditingController();
  final _yazarController = TextEditingController();
  final _yayineviController = TextEditingController();
  final _isbnController = TextEditingController();
  List<Map<String, String>> wishlist = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistJson = prefs.getString('wishlist');
    if (wishlistJson != null) {
      setState(() {
        wishlist = List<Map<String, String>>.from(
          json.decode(wishlistJson).map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist', json.encode(wishlist));
  }

  void _addToWishlist() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        wishlist.add({
          "kitapAdi": _kitapAdiController.text,
          "yazar": _yazarController.text,
          "yayinevi": _yayineviController.text,
          "isbn": _isbnController.text,
        });
        _kitapAdiController.clear();
        _yazarController.clear();
        _yayineviController.clear();
        _isbnController.clear();
      });
      _saveWishlist();
    }
  }

  void _removeAndMoveToBooks(int index) {
    final book = wishlist[index];
    setState(() {
      wishlist.removeAt(index);
    });
    _saveWishlist();
    if (widget.onMoveToBooks != null) {
      widget.onMoveToBooks!(book);
    }
  }

  void _deleteWishlistBook(int index) {
    setState(() {
      wishlist.removeAt(index);
    });
    _saveWishlist();
  }

  void _addToBooks(int index) async {
    final book = wishlist[index];
    // Remove from wishlist
    setState(() {
      wishlist.removeAt(index);
    });
    _saveWishlist();
    // Add to books list
    final prefs = await SharedPreferences.getInstance();
    final String? kitapJson = prefs.getString('kitapListesi');
    List<Map<String, String>> kitapListesi = kitapJson != null
        ? List<Map<String, String>>.from(
            json.decode(kitapJson).map((e) => Map<String, String>.from(e)),
          )
        : [];
    kitapListesi.add(book);
    await prefs.setString('kitapListesi', json.encode(kitapListesi));
  }

  void _editWishlistBook(int index) {
    final kitap = wishlist[index];
    _kitapAdiController.text = kitap["kitapAdi"] ?? "";
    _yazarController.text = kitap["yazar"] ?? "";
    _yayineviController.text = kitap["yayinevi"] ?? "";
    _isbnController.text = kitap["isbn"] ?? "";
    final _editFormKey = GlobalKey<FormState>();
    final isTurkish = widget.locale?.languageCode == 'tr';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isTurkish ? "Kitap Düzenle" : "Edit Book"),
          content: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _kitapAdiController,
                    decoration: InputDecoration(
                      labelText: isTurkish ? 'Kitap Adı' : 'Book Name',
                    ),
                    validator: (value) => value!.isEmpty
                        ? (isTurkish
                              ? 'Kitap adı gerekli'
                              : 'Book name required')
                        : null,
                  ),
                  TextFormField(
                    controller: _yazarController,
                    decoration: InputDecoration(
                      labelText: isTurkish ? 'Yazar Adı' : 'Author',
                    ),
                  ),
                  TextFormField(
                    controller: _yayineviController,
                    decoration: InputDecoration(
                      labelText: isTurkish ? 'Yayınevi' : 'Publisher',
                    ),
                  ),
                  TextFormField(
                    controller: _isbnController,
                    decoration: InputDecoration(labelText: 'ISBN'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _kitapAdiController.clear();
                _yazarController.clear();
                _yayineviController.clear();
                _isbnController.clear();
                Navigator.pop(context);
              },
              child: Text(isTurkish ? "İptal" : "Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editFormKey.currentState!.validate()) {
                  setState(() {
                    wishlist[index] = {
                      "kitapAdi": _kitapAdiController.text,
                      "yazar": _yazarController.text,
                      "yayinevi": _yayineviController.text,
                      "isbn": _isbnController.text,
                    };
                  });
                  _saveWishlist();
                  _kitapAdiController.clear();
                  _yazarController.clear();
                  _yayineviController.clear();
                  _isbnController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text(isTurkish ? "Kaydet" : "Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTurkish = widget.locale?.languageCode == 'tr';
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextFormField(
                  controller: _kitapAdiController,
                  decoration: InputDecoration(
                    labelText: isTurkish ? 'Kitap Adı' : 'Book Name',
                  ),
                  validator: (value) => value!.isEmpty
                      ? (isTurkish ? 'Kitap adı gerekli' : 'Book name required')
                      : null,
                ),
                TextFormField(
                  controller: _yazarController,
                  decoration: InputDecoration(
                    labelText: isTurkish ? 'Yazar Adı' : 'Author',
                  ),
                ),
                TextFormField(
                  controller: _yayineviController,
                  decoration: InputDecoration(
                    labelText: isTurkish ? 'Yayınevi' : 'Publisher',
                  ),
                ),
                TextFormField(
                  controller: _isbnController,
                  decoration: InputDecoration(labelText: 'ISBN'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addToWishlist,
                  child: Text(isTurkish ? "Listeye Ekle" : "Add to Wishlist"),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: wishlist.isEmpty
              ? Center(
                  child: Text(
                    isTurkish ? 'Alınacak listesi boş.' : 'Wishlist is empty.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) {
                    final kitap = wishlist[index];
                    return ListTile(
                      leading: Icon(Icons.bookmark),
                      title: Text(kitap["kitapAdi"] ?? ""),
                      subtitle: Text(
                        isTurkish
                            ? "Yazar: ${kitap["yazar"]}, Yayınevi: ${kitap["yayinevi"]}, ISBN: ${kitap["isbn"]}"
                            : "Author: ${kitap["yazar"]}, Publisher: ${kitap["yayinevi"]}, ISBN: ${kitap["isbn"]}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.green),
                            tooltip: isTurkish
                                ? "Kitaplara Ekle"
                                : "Add to Books",
                            onPressed: () => _addToBooks(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            tooltip: isTurkish ? "Düzenle" : "Edit",
                            onPressed: () => _editWishlistBook(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: isTurkish ? "Sil" : "Delete",
                            onPressed: () => _deleteWishlistBook(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
