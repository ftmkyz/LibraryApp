import 'package:flutter/material.dart';
import 'package:library_app/widgets/textarea.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class KitaplarSayfasi extends StatefulWidget {
  const KitaplarSayfasi({super.key});
  @override
  State<KitaplarSayfasi> createState() => _KitaplarSayfasiState();
}

class _KitaplarSayfasiState extends State<KitaplarSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _kitapAdiController = TextEditingController();
  final _yazarController = TextEditingController();
  final _yayineviController = TextEditingController();
  final _isbnController = TextEditingController();

  List<Map<String, String>> kitapListesi = [];

  String _searchText = '';
  bool _showSearchField = false;

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

    final editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final inheritedLocale = Localizations.localeOf(context);
        final isTurkish = inheritedLocale.languageCode == 'tr';
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
                  TextAreaGroup(
                    controller: _isbnController,
                    textType: 'TextFormField',
                    textHeight: 50,
                    textWidth: MediaQuery.of(context).size.width,
                    hintText: 'ISBN',
                    errorText: '',
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
                if (editFormKey.currentState!.validate()) {
                  setState(() {
                    kitapListesi[index] = {
                      "kitapAdi": _kitapAdiController.text,
                      "yazar": _yazarController.text,
                      "yayinevi": _yayineviController.text,
                      "isbn": _isbnController.text,
                    };
                  });
                  _kitaplariKaydet();
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
                Row(
                  children: [
                    Expanded(
                      child: _showSearchField
                          ? SizedBox(
                              width: 200,
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: isTurkish
                                      ? 'Kitaplarda Ara'
                                      : 'Search Books',
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
                        color: const Color.fromARGB(255, 8, 191, 173),
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
                        color: const Color.fromARGB(255, 77, 121, 3),
                      ),
                      onPressed: () {
                        final inheritedLocale = Localizations.localeOf(context);
                        final isTurkish = inheritedLocale.languageCode == 'tr';
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
                                      TextAreaGroup(
                                        controller: _isbnController,
                                        textType: 'TextFormField',
                                        textHeight: 50,
                                        textWidth: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        hintText: 'ISBN',
                                        errorText: '',
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
                                      setState(() {
                                        kitapListesi.add({
                                          "kitapAdi": _kitapAdiController.text,
                                          "yazar": _yazarController.text,
                                          "yayinevi": _yayineviController.text,
                                          "isbn": _isbnController.text,
                                        });
                                      });
                                      _kitaplariKaydet();
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
                // SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: _kitapEkle,
                //   child: Text(isTurkish ? "Kitap Ekle" : "Add Book"),
                // ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: kitapListesi.where((kitap) {
              final query = _searchText.toLowerCase();
              return kitap["kitapAdi"]?.toLowerCase().contains(query) == true ||
                  kitap["yazar"]?.toLowerCase().contains(query) == true ||
                  kitap["yayinevi"]?.toLowerCase().contains(query) == true ||
                  kitap["isbn"]?.toLowerCase().contains(query) == true;
            }).length,
            itemBuilder: (context, index) {
              final filteredList = kitapListesi.where((kitap) {
                final query = _searchText.toLowerCase();
                return kitap["kitapAdi"]?.toLowerCase().contains(query) ==
                        true ||
                    kitap["yazar"]?.toLowerCase().contains(query) == true ||
                    kitap["yayinevi"]?.toLowerCase().contains(query) == true ||
                    kitap["isbn"]?.toLowerCase().contains(query) == true;
              }).toList();
              final kitap = filteredList[index];
              return ListTile(
                leading: Icon(Icons.book),
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
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _kitapDuzenle(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _kitapSil(index),
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
