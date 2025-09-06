// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:library_app/widgets/textarea.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final _formKey = GlobalKey<FormState>();
  final _kitapAdiController = TextEditingController();
  final _yazarController = TextEditingController();
  final _yayineviController = TextEditingController();
  final _isbnController = TextEditingController();
  final _sayfaSayisiController = TextEditingController();
  final _okunanSayfaController = TextEditingController();
  // ignore: prefer_final_fields
  bool _tamamlandi = false;

  List<Map<String, String>> kitapListesi = [];

  String _searchText = '';
  bool _showSearchField = false;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _kitaplariYukle();
  }

  Future<void> _kitaplariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? kitapJson = prefs.getString('kitapListesi');
    if (kitapJson != null) {
      setState(() {
        kitapListesi = List<Map<String, String>>.from(
          json.decode(kitapJson).map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }

  Future<void> _kitaplariKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kitapListesi', json.encode(kitapListesi));
  }

  void _kitapSil(int index) {
    setState(() {
      kitapListesi.removeAt(index);
    });
    _kitaplariKaydet();
  }

  void _kitapDuzenle(int index) {
    final kitap = kitapListesi[index];
    _kitapAdiController.text = kitap["kitapAdi"] ?? "";
    _yazarController.text = kitap["yazar"] ?? "";
    _yayineviController.text = kitap["yayinevi"] ?? "";
    _isbnController.text = kitap["isbn"] ?? "";
    _sayfaSayisiController.text = kitap["sayfaSayisi"] ?? "";
    _okunanSayfaController.text = kitap["okunanSayfa"] ?? "";
    final editFormKey = GlobalKey<FormState>();
    final inheritedLocale = Localizations.localeOf(context);
    final isTurkish = inheritedLocale.languageCode == 'tr';
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
                  TextAreaGroup(
                    controller: _kitapAdiController,
                    textType: 'TextFormField',
                    textHeight: 50,
                    textWidth: MediaQuery.of(context).size.width,
                    hintText: isTurkish ? 'Kitap Adı' : 'Book Name',
                    errorText: isTurkish
                        ? 'Kitap adı gerekli'
                        : 'Book name required',
                  ),
                  TextAreaGroup(
                    controller: _yazarController,
                    textType: 'TextFormField',
                    textHeight: 50,
                    textWidth: MediaQuery.of(context).size.width,
                    hintText: isTurkish ? 'Yazar Adı' : 'Author',
                    errorText: '',
                  ),
                  TextAreaGroup(
                    controller: _yayineviController,
                    textType: 'TextFormField',
                    textHeight: 50,
                    textWidth: MediaQuery.of(context).size.width,
                    hintText: isTurkish ? 'Yayınevi' : 'Publisher',
                    errorText: '',
                  ),
                  // ISBN alanı: TextField'ın sonunda kamera ve search ikonları yanyana
                  Row(
                    children: [
                      Expanded(
                        child: TextAreaGroup(
                          controller: _isbnController,
                          textType: 'TextFormField',
                          textHeight: 50,
                          textWidth: MediaQuery.of(context).size.width,
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
                          await _fillBookFieldsFromIsbn(_isbnController.text);
                        },
                      ),
                    ],
                  ),
                  TextAreaGroup(
                    controller: _sayfaSayisiController,
                    textType: 'TextFormField',
                    textHeight: 50,
                    textWidth: MediaQuery.of(context).size.width,
                    hintText: isTurkish ? 'Sayfa Sayısı' : 'Page Count',
                    errorText: '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextAreaGroup(
                    controller: _okunanSayfaController,
                    textType: 'TextFormField',
                    textHeight: 50,
                    textWidth: MediaQuery.of(context).size.width,
                    hintText: isTurkish ? 'Okunan Sayfa' : 'Pages Read',
                    errorText: '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // Add validator to TextAreaGroup by passing it as a parameter
                    validator: (value) {
                      final total =
                          int.tryParse(_sayfaSayisiController.text) ?? 0;
                      final read = int.tryParse(value ?? '') ?? 0;
                      if (read > total) {
                        return isTurkish
                            ? 'Okunan sayfa toplamdan fazla olamaz'
                            : 'Pages read cannot exceed total pages';
                      }
                      return null;
                    },
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
                _sayfaSayisiController.clear();
                _okunanSayfaController.clear();
                Navigator.pop(context);
              },
              child: Text(isTurkish ? "İptal" : "Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (editFormKey.currentState!.validate()) {
                  setState(() {
                    kitapListesi[index] = {
                      "kitapAdi": _kitapAdiController.text,
                      "yazar": _yazarController.text,
                      "yayinevi": _yayineviController.text,
                      "isbn": _isbnController.text,
                      "sayfaSayisi": _sayfaSayisiController.text,
                      "okunanSayfa": _okunanSayfaController.text,
                      "tamamlandi": _tamamlandi.toString(),
                    };
                  });
                  _kitaplariKaydet();
                  _kitapAdiController.clear();
                  _yazarController.clear();
                  _yayineviController.clear();
                  _isbnController.clear();
                  _sayfaSayisiController.clear();
                  _okunanSayfaController.clear();
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

  @override
  Widget build(BuildContext context) {
    // Get locale from parent (HomePage)
    final inheritedLocale = Localizations.localeOf(context);
    final isTurkish = inheritedLocale.languageCode == 'tr';
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                // Arama ve + ikonları tek satırda
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black26
                                          : Colors.grey.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  key: ValueKey(1),
                                  decoration: InputDecoration(
                                    hintText: isTurkish
                                        ? 'Kitaplarda Ara'
                                        : 'Search Books',
                                    isDense: true,
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
                                    });
                                  },
                                ),
                              )
                            : SizedBox(key: ValueKey(2)),
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
                          Icons.search_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _showSearchField = !_showSearchField;
                          });
                        },
                        tooltip: isTurkish ? 'Ara' : 'Search',
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
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          final inheritedLocale = Localizations.localeOf(
                            context,
                          );
                          final isTurkish =
                              inheritedLocale.languageCode == 'tr';
                          final addFormKey = GlobalKey<FormState>();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  isTurkish ? "Kitap Ekle" : "Add Book",
                                ),
                                content: SingleChildScrollView(
                                  child: Form(
                                    key: addFormKey,
                                    child: Column(
                                      children: [
                                        TextAreaGroup(
                                          controller: _kitapAdiController,
                                          textType: 'TextFormField',
                                          textHeight: 50,
                                          textWidth: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          hintText: isTurkish
                                              ? 'Kitap Adı'
                                              : 'Book Name',
                                          errorText: isTurkish
                                              ? 'Kitap adı gerekli'
                                              : 'Book name required',
                                        ),
                                        TextAreaGroup(
                                          controller: _yazarController,
                                          textType: 'TextFormField',
                                          textHeight: 50,
                                          textWidth: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          hintText: isTurkish
                                              ? 'Yazar Adı'
                                              : 'Author',
                                          errorText: '',
                                        ),
                                        TextAreaGroup(
                                          controller: _yayineviController,
                                          textType: 'TextFormField',
                                          textHeight: 50,
                                          textWidth: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          hintText: isTurkish
                                              ? 'Yayınevi'
                                              : 'Publisher',
                                          errorText: '',
                                        ),
                                        // ISBN alanı: TextField'ın sonunda kamera ve search ikonları yanyana
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
                                        TextAreaGroup(
                                          controller: _sayfaSayisiController,
                                          textType: 'TextFormField',
                                          textHeight: 50,
                                          textWidth: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          hintText: isTurkish
                                              ? 'Sayfa Sayısı'
                                              : 'Page Count',
                                          errorText: '',
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                        TextAreaGroup(
                                          controller: _okunanSayfaController,
                                          textType: 'TextFormField',
                                          textHeight: 50,
                                          textWidth: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          hintText: isTurkish
                                              ? 'Okunan Sayfa'
                                              : 'Pages Read',
                                          errorText: '',
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
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
                                      _sayfaSayisiController.clear();
                                      _okunanSayfaController.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Text(isTurkish ? "İptal" : "Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (addFormKey.currentState!.validate()) {
                                        setState(() {
                                          kitapListesi.add({
                                            "kitapAdi":
                                                _kitapAdiController.text,
                                            "yazar": _yazarController.text,
                                            "yayinevi":
                                                _yayineviController.text,
                                            "isbn": _isbnController.text,
                                            "sayfaSayisi":
                                                _sayfaSayisiController.text,
                                            "okunanSayfa":
                                                _okunanSayfaController.text,
                                          });
                                        });
                                        _kitaplariKaydet();
                                        _kitapAdiController.clear();
                                        _yazarController.clear();
                                        _yayineviController.clear();
                                        _isbnController.clear();
                                        _sayfaSayisiController.clear();
                                        _okunanSayfaController.clear();
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
                        tooltip: isTurkish ? 'Ekle' : 'Add',
                      ),
                    ),
                  ],
                ),
                // Filtre dropdown klasik sade haliyle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      value: _filterType,
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(isTurkish ? 'Tüm Kitaplar' : 'All'),
                        ),
                        DropdownMenuItem(
                          value: 'read',
                          child: Text(isTurkish ? 'Okunanlar' : 'Read'),
                        ),
                        DropdownMenuItem(
                          value: 'unread',
                          child: Text(isTurkish ? 'Okunmayanlar' : 'Unread'),
                        ),
                        DropdownMenuItem(
                          value: 'az',
                          child: Text(isTurkish ? 'A-Z' : 'A-Z'),
                        ),
                        DropdownMenuItem(
                          value: 'za',
                          child: Text(isTurkish ? 'Z-A' : 'Z-A'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _filterType = val ?? 'all';
                        });
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
              List<Map<String, String>> filteredList = kitapListesi.where((
                kitap,
              ) {
                final query = _searchText.toLowerCase();
                final isRead =
                    (kitap["tamamlandi"] == "true") ||
                    ((kitap["sayfaSayisi"] ?? "") != "" &&
                        (kitap["okunanSayfa"] ?? "") != "" &&
                        kitap["sayfaSayisi"] == kitap["okunanSayfa"]);
                bool matchesFilter = true;
                if (_filterType == 'read') matchesFilter = isRead;
                if (_filterType == 'unread') matchesFilter = !isRead;
                return (kitap["kitapAdi"]?.toLowerCase().contains(query) ==
                            true ||
                        kitap["yazar"]?.toLowerCase().contains(query) == true ||
                        kitap["yayinevi"]?.toLowerCase().contains(query) ==
                            true ||
                        kitap["isbn"]?.toLowerCase().contains(query) == true) &&
                    matchesFilter;
              }).toList();
              if (_filterType == 'az') {
                filteredList.sort(
                  (a, b) =>
                      (a["kitapAdi"] ?? "").compareTo(b["kitapAdi"] ?? ""),
                );
              } else if (_filterType == 'za') {
                filteredList.sort(
                  (a, b) =>
                      (b["kitapAdi"] ?? "").compareTo(a["kitapAdi"] ?? ""),
                );
              }
              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final kitap = filteredList[index];
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
                      leading: Icon(Icons.menu_book, color: theme.primaryColor),
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
                          Text(
                            isTurkish
                                ? "Sayfa: ${kitap["sayfaSayisi"]}"
                                : "Pages: ${kitap["sayfaSayisi"]}",
                            style: TextStyle(fontSize: 14),
                          ),
                          if ((kitap["sayfaSayisi"] ?? "").isNotEmpty &&
                              (kitap["okunanSayfa"] ?? "").isNotEmpty)
                            Builder(
                              builder: (context) {
                                final total =
                                    int.tryParse(kitap["sayfaSayisi"] ?? "") ??
                                    0;
                                final read =
                                    int.tryParse(kitap["okunanSayfa"] ?? "") ??
                                    0;
                                final isCompleted =
                                    kitap["tamamlandi"] == "true";
                                final percent = (isCompleted && total > 0)
                                    ? 1.0
                                    : total > 0
                                    ? (read / total).clamp(0.0, 1.0)
                                    : 0.0;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: percent,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      isTurkish
                                          ? "%${(percent * 100).toStringAsFixed(0)} okundu"
                                          : "%${(percent * 100).toStringAsFixed(0)} read",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value:
                                (kitap["tamamlandi"] == "true") ||
                                ((kitap["sayfaSayisi"] ?? "") != "" &&
                                    (kitap["okunanSayfa"] ?? "") != "" &&
                                    kitap["sayfaSayisi"] ==
                                        kitap["okunanSayfa"]),
                            onChanged: (val) {
                              setState(() {
                                kitapListesi[index]["tamamlandi"] = val
                                    .toString();
                                if (val == true) {
                                  // Set progress to 100% and pages read = total pages
                                  final total =
                                      kitapListesi[index]["sayfaSayisi"] ?? "";
                                  kitapListesi[index]["okunanSayfa"] = total;
                                } else {
                                  // If unchecked, reset pages read to 0
                                  kitapListesi[index]["okunanSayfa"] = "0";
                                }
                              });
                              _kitaplariKaydet();
                            },
                            activeColor: theme.primaryColor,
                            checkColor: theme.cardColor,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: theme.colorScheme.secondary,
                            ),
                            onPressed: () => _kitapDuzenle(index),
                            tooltip: isTurkish ? 'Düzenle' : 'Edit',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.red[300] : Colors.red,
                            ),
                            onPressed: () => _kitapSil(index),
                            tooltip: isTurkish ? 'Sil' : 'Delete',
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
