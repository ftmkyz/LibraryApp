// ignore_for_file: deprecated_member_use, depend_on_referenced_packages, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:library_app/widgets/EqualHeightFlipCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'package:library_app/widgets/textarea.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
  String lastsearchvalue = '';
  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _fillBookFieldsFromIsbn(String isbn) async {
    // 1) OpenLibrary API
    final openUrl =
        'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data';

    try {
      final openResponse = await http.get(Uri.parse(openUrl));

      if (openResponse.statusCode == 200) {
        final data = json.decode(openResponse.body);
        final book = data['ISBN:$isbn'];

        // Eğer OpenLibrary bulduysa → direkt doldur ve çık
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

          return; // OpenLibrary bulundu → fonksiyondan çık
        }
      }
    } catch (_) {
      // OpenLibrary hatalarını önemseme
    }

    final googleUrl =
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn';

    try {
      final googleResponse = await http.get(Uri.parse(googleUrl));

      if (googleResponse.statusCode == 200) {
        final data = json.decode(googleResponse.body);

        if (data['totalItems'] > 0) {
          final info = data['items'][0]['volumeInfo'];

          setState(() {
            _kitapAdiController.text = info['title'] ?? '';
            _yazarController.text = info['authors'] != null
                ? info['authors'].join(', ')
                : '';
            _yayineviController.text = info['publisher'] ?? '';
          });
        }
      }
    } catch (_) {
      // Google Books hatalarını önemseme
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

  Future<void> _importIsbnFromPdf(String path) async {
    final bytes = await File(path).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    List<Map<String, String>> importedBooks = [];
    Map<String, String> currentBook = {};
    String currentField = "";

    for (final line in lines) {
      if (line.startsWith("Kitap")) {
        // Yeni kitap başlıyor
        currentBook = {"kitapAdi": "", "yazar": "", "yayinevi": "", "isbn": ""};
        currentField = "kitapAdi";
      } else if (line.startsWith("Adi:")) {
        currentField = "kitapAdi";
      } else if (line.startsWith("Yazar:")) {
        currentField = "yazar";
      } else if (line.startsWith("Yayinevi:")) {
        currentField = "yayinevi";
      } else if (line.startsWith("ISBN:")) {
        currentField = "isbn";
      } else {
        // Alanın devamı
        if (currentField.isNotEmpty) {
          currentBook[currentField] =
              (currentBook[currentField] ?? "") + " " + line;
        }
      }

      // ISBN dolunca kitabı ekle
      if (currentField == "isbn" && line.startsWith("ISBN:") == false) {
        final isbn =
            currentBook["isbn"]?.replaceAll(RegExp(r'[-\s]'), '') ?? "";
        if (isbn.isNotEmpty) {
          currentBook["isbn"] = isbn;
          importedBooks.add(currentBook);
          currentBook = {};
          currentField = "";
        }
      }
    }

    // Sende olmayan ISBN’leri ekle
    final existingIsbns = {
      ...wishlist.map((b) => b['isbn'] ?? ''),
      ...kitapListesi.map((b) => b['isbn'] ?? ''),
    };

    for (final book in importedBooks) {
      final isbn = book["isbn"] ?? "";
      if (isbn.isEmpty || existingIsbns.contains(isbn)) continue;

      await _fillBookFieldsFromIsbn(isbn);

      setState(() {
        wishlist.add({
          "kitapAdi": _kitapAdiController.text.isNotEmpty
              ? _kitapAdiController.text
              : book["kitapAdi"] ?? "Bilinmeyen",
          "yazar": _yazarController.text.isNotEmpty
              ? _yazarController.text
              : book["yazar"] ?? "Bilinmeyen",
          "yayinevi": _yayineviController.text.isNotEmpty
              ? _yayineviController.text
              : book["yayinevi"] ?? "Bilinmeyen",
          "isbn": isbn,
        });
      });
    }

    _saveWishlist();
  }

  Future<void> _pickPdfAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      await _importIsbnFromPdf(result.files.single.path!);
    }
  }

  void _deleteWishlistBook(Map<String, String> kitap) {
    final originalIndex = wishlist.indexWhere((k) {
      if ((kitap["isbn"] ?? "").isNotEmpty) {
        return k["isbn"] == kitap["isbn"];
      } else {
        return k["kitapAdi"] == kitap["kitapAdi"];
      }
    });
    if (originalIndex == -1) return;
    setState(() {
      wishlist.removeAt(originalIndex);
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

  void _editWishlistBook(Map<String, String> kitap) {
    final index = wishlist.indexWhere((k) {
      if ((kitap["isbn"] ?? "").isNotEmpty) {
        return k["isbn"] == kitap["isbn"];
      } else {
        return k["kitapAdi"] == kitap["kitapAdi"];
      }
    });
    _kitapAdiController.text = kitap["kitapAdi"] ?? "";
    _yazarController.text = kitap["yazar"] ?? "";
    _yayineviController.text = kitap["yayinevi"] ?? "";
    _isbnController.text = kitap["isbn"] ?? "";
    final editFormKey = GlobalKey<FormState>();
    final isTurkish = widget.locale?.languageCode == 'tr';
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isTurkish ? "Kitap Düzenle" : "Edit Book",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: editFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _kitapAdiController,
                    decoration: InputDecoration(
                      labelText: isTurkish ? 'Kitap Adı' : 'Book Name',
                      labelStyle: TextStyle(
                        color: theme
                            .colorScheme
                            .error, // Label rengi buradan gelir
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    validator: (value) => value!.isEmpty
                        ? (isTurkish
                              ? 'Kitap adı gerekli'
                              : 'Book name required')
                        : null,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  TextFormField(
                    controller: _yazarController,
                    decoration: InputDecoration(
                      labelText: isTurkish ? 'Yazar Adı' : 'Author',
                      labelStyle: TextStyle(
                        color: theme
                            .colorScheme
                            .error, // Label rengi buradan gelir
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  TextFormField(
                    controller: _yayineviController,
                    decoration: InputDecoration(
                      labelText: isTurkish ? 'Yayınevi' : 'Publisher',
                      labelStyle: TextStyle(
                        color: theme
                            .colorScheme
                            .error, // Label rengi buradan gelir
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  TextFormField(
                    controller: _isbnController,
                    decoration: InputDecoration(
                      labelText: 'ISBN',
                      labelStyle: TextStyle(
                        color: theme
                            .colorScheme
                            .error, // Label rengi buradan gelir
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
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
              child: Text(
                isTurkish ? "İptal" : "Cancel",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // <-- async ekle!
                if (editFormKey.currentState!.validate()) {
                  final newIsbn = _isbnController.text.trim();
                  final isbnVar = wishlist.any(
                    (kitap) => kitap["isbn"] == newIsbn,
                  );
                  final isbnExistbooks = kitapListesi.any(
                    (kitap) => kitap["isbn"] == newIsbn,
                  );
                  if (wishlist[index]["isbn"] != newIsbn &&
                      (isbnVar || isbnExistbooks)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isTurkish
                              ? "Bu ISBN başka bir kitap için eklenmiş!"
                              : "This ISBN is already added! for another book",
                        ),
                        backgroundColor: theme.colorScheme.error,
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
              child: Text(
                isTurkish ? "Kaydet" : "Save",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTurkish = widget.locale?.languageCode == 'tr';
    final theme = Theme.of(context);
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
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: _showSearchField
                            ? SizedBox(
                                key: const ValueKey(1),
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        // color: isDark
                                        //     ? Colors.black54
                                        //     : Colors.grey.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        // offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    initialValue: lastsearchvalue,
                                    key: const ValueKey(1),
                                    decoration: InputDecoration(
                                      labelText: isTurkish
                                          ? 'İsteklerde Ara'
                                          : 'Search Wishlist',
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(fontSize: 16),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchText = value;
                                        lastsearchvalue = value;
                                      });
                                    },
                                  ),
                                ),
                              )
                            : SizedBox(key: ValueKey(2)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black26
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.upload_file,
                          // color: Theme.of(context).primaryColor,
                          color: theme.colorScheme.onSurface,
                        ),
                        tooltip: isTurkish
                            ? 'PDF’den ISBN Import'
                            : 'Import ISBN from PDF',
                        onPressed: _pickPdfAndImport,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black26
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.search_outlined,
                          // color: Theme.of(context).primaryColor,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () {
                          setState(() {
                            _showSearchField = !_showSearchField;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black26
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () {
                          final isTurkish = widget.locale?.languageCode == 'tr';
                          final addFormKey = GlobalKey<FormState>();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  isTurkish
                                      ? "İstek Ekle"
                                      : "Add Wishlist Item",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'BebasNeue', //??
                                    color: theme.colorScheme.onSurface,
                                  ),
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
                                    child: Text(
                                      isTurkish ? "İptal" : "Cancel",
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
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
                                              backgroundColor:
                                                  theme.colorScheme.error,
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
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                            ),
                                          );
                                          return;
                                        }
                                        setState(() {
                                          wishlist.add({
                                            "kitapAdi":
                                                _kitapAdiController.text,
                                            "yazar": _yazarController.text,
                                            "yayinevi":
                                                _yayineviController.text,
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
                                    child: Text(
                                      isTurkish ? "Ekle" : "Add",
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
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
                  final kitap = filteredList[index];
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;

                  // Ön yüz
                  final frontChild = Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.cardColor.withOpacity(0.9),
                          theme.colorScheme.onSurface.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: theme.colorScheme.onSurface,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kitap["kitapAdi"] ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                isTurkish
                                    ? "Yazar: ${kitap["yazar"]}"
                                    : "Author: ${kitap["yazar"]}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );

                  // Arka yüz
                  final backChild = Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.cardColor.withOpacity(0.9),
                          theme.colorScheme.onSurface.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTurkish
                              ? "Yayınevi: ${kitap["yayinevi"]}"
                              : "Publisher: ${kitap["yayinevi"]}",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          "ISBN: ${kitap["isbn"]}",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: theme.colorScheme.onSurface,
                              ),
                              tooltip: isTurkish
                                  ? "Kitaplara Ekle"
                                  : "Add to Books",
                              onPressed: () => _addToBooks(index),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.onSurface,
                              ),
                              tooltip: isTurkish ? "Düzenle" : "Edit",
                              onPressed: () => _editWishlistBook(kitap),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.error,
                              ),
                              tooltip: isTurkish ? "Sil" : "Delete",
                              onPressed: () => _deleteWishlistBook(kitap),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );

                  return Container(
                    margin: EdgeInsets.only(
                      // horizontal: 12,
                      // vertical: 8,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
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
                    child: EqualHeightFlipCard(
                      front: frontChild,
                      back: backChild,
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
