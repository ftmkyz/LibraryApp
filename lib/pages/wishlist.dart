// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'package:library_app/widgets/textarea.dart';

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
  List<Map<String, String>> kitapListesi = [];
  String _searchText = '';
  bool _showSearchField = false;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _fillBookFieldsFromIsbn(String isbn) async {
    final url =
        'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final book = data['ISBN:$isbn'];
      if (book != null) {
        final title = book['title'] ?? '';
        final authors = book['authors'] as List<dynamic>?;
        final author = authors != null && authors.isNotEmpty
            ? authors[0]['name']
            : '';
        final publishers = book['publishers'] as List<dynamic>?;
        final publisher = publishers != null && publishers.isNotEmpty
            ? publishers[0]['name']
            : '';
        setState(() {
          _kitapAdiController.text = title;
          _yazarController.text = author;
          _yayineviController.text = publisher;
        });
      }
    }
  }

  Future<void> _scanIsbn() async {
    var result = await BarcodeScanner.scan();
    if (result.type == ResultType.Barcode) {
      setState(() {
        _isbnController.text = result.rawContent;
      });
      await _fillBookFieldsFromIsbn(result.rawContent);
    }
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
    final String? kitapJson = prefs.getString('kitapListesi');
    if (kitapJson != null) {
      setState(() {
        kitapListesi = List<Map<String, String>>.from(
          json.decode(kitapJson).map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist', json.encode(wishlist));
  }

  // void _removeAndMoveToBooks(int index) {
  //   final book = wishlist[index];
  //   setState(() {
  //     wishlist.removeAt(index);
  //   });
  //   _saveWishlist();
  //   if (widget.onMoveToBooks != null) {
  //     widget.onMoveToBooks!(book);
  //   }
  // }

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
    final editFormKey = GlobalKey<FormState>();
    final isTurkish = widget.locale?.languageCode == 'tr';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isTurkish ? "Kitap Düzenle" : "Edit Book"),
          content: SingleChildScrollView(
            child: Form(
              key: editFormKey,
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
                // <-- async ekle!
                if (editFormKey.currentState!.validate()) {
                  final yeniIsbn = _isbnController.text.trim();
                  final isbnVar = wishlist.any(
                    (kitap) => kitap["isbn"] == yeniIsbn,
                  );
                  if (isbnVar) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isTurkish
                              ? "Bu ISBN zaten eklenmiş!"
                              : "This ISBN is already added!",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
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
                  // ignore: use_build_context_synchronously
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
                Row(
                  children: [
                    Expanded(
                      child: _showSearchField
                          ? SizedBox(
                              width: 200,
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: isTurkish
                                      ? 'İsteklerde Ara'
                                      : 'Search Wishlist',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchText = value;
                                  });
                                },
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSearchField = !_showSearchField;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        final isTurkish = widget.locale?.languageCode == 'tr';
                        final addFormKey = GlobalKey<FormState>();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                isTurkish ? "İstek Ekle" : "Add Wishlist Item",
                              ),
                              content: SingleChildScrollView(
                                child: Form(
                                  key: addFormKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _kitapAdiController,
                                        decoration: InputDecoration(
                                          labelText: isTurkish
                                              ? 'Kitap Adı'
                                              : 'Book Name',
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
                                          labelText: isTurkish
                                              ? 'Yazar Adı'
                                              : 'Author',
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _yayineviController,
                                        decoration: InputDecoration(
                                          labelText: isTurkish
                                              ? 'Yayınevi'
                                              : 'Publisher',
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextAreaGroup(
                                              controller: _isbnController,
                                              textType: 'TextFormField',
                                              textHeight: 50,
                                              textWidth: MediaQuery.of(
                                                context,
                                              ).size.width,
                                              hintText: 'ISBN',
                                              errorText: '',
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.camera_alt),
                                            tooltip: 'ISBN Barkod Okut',
                                            onPressed: _scanIsbn,
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.search),
                                            tooltip: 'ISBN ile kitap ara',
                                            onPressed: () async {
                                              await _fillBookFieldsFromIsbn(
                                                _isbnController.text,
                                              );
                                            },
                                          ),
                                        ],
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
                                    if (addFormKey.currentState!.validate()) {
                                      final newIsbn = _isbnController.text
                                          .trim();
                                      final isbnExist = wishlist.any(
                                        (kitap) => kitap["isbn"] == newIsbn,
                                      );

                                      final isbnExistbooks = kitapListesi.any(
                                        (kitap) => kitap["isbn"] == newIsbn,
                                      );
                                      if (isbnExist) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isTurkish
                                                  ? "Bu ISBN zaten eklenmiş!"
                                                  : "This ISBN is already added!",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      if (isbnExistbooks) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isTurkish
                                                  ? "Bu ISBN zaten eklenmiş!"
                                                  : "This ISBN is already added!",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() {
                                        wishlist.add({
                                          "kitapAdi": _kitapAdiController.text,
                                          "yazar": _yazarController.text,
                                          "yayinevi": _yayineviController.text,
                                          "isbn": _isbnController.text,
                                        });
                                      });
                                      _saveWishlist();
                                      _kitapAdiController.clear();
                                      _yazarController.clear();
                                      _yayineviController.clear();
                                      _isbnController.clear();
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(isTurkish ? "Ekle" : "Add"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              List<Map<String, String>> filteredList = wishlist.where((kitap) {
                final query = _searchText.toLowerCase();
                (kitap["tamamlandi"] == "true") ||
                    ((kitap["sayfaSayisi"] ?? "") != "" &&
                        (kitap["okunanSayfa"] ?? "") != "" &&
                        kitap["sayfaSayisi"] == kitap["okunanSayfa"]);
                bool matchesFilter = true;
                return (kitap["kitapAdi"]?.toLowerCase().contains(query) ==
                            true ||
                        kitap["yazar"]?.toLowerCase().contains(query) == true ||
                        kitap["yayinevi"]?.toLowerCase().contains(query) ==
                            true ||
                        kitap["isbn"]?.toLowerCase().contains(query) == true) &&
                    matchesFilter;
              }).toList();

              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final kitap = wishlist[index];
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black54
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Icon(Icons.bookmark, color: theme.primaryColor),
                      title: Text(
                        kitap["kitapAdi"] ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTurkish
                                ? "Yazar: ${kitap["yazar"]}"
                                : "Author: ${kitap["yazar"]}",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            isTurkish
                                ? "Yayınevi: ${kitap["yayinevi"]}"
                                : "Publisher: ${kitap["yayinevi"]}",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "ISBN: ${kitap["isbn"]}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color: theme.colorScheme.secondary,
                            ),
                            tooltip: isTurkish
                                ? "Kitaplara Ekle"
                                : "Add to Books",
                            onPressed: () => _addToBooks(index),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: theme.colorScheme.secondary,
                            ),
                            tooltip: isTurkish ? "Düzenle" : "Edit",
                            onPressed: () => _editWishlistBook(index),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.red[300] : Colors.red,
                            ),
                            tooltip: isTurkish ? "Sil" : "Delete",
                            onPressed: () => _deleteWishlistBook(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
