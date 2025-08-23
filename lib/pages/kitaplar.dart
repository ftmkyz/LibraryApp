import 'package:flutter/material.dart';
import 'package:library_app/widgets/textarea.dart';

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

  void _kitapEkle() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        kitapListesi.add({
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextAreaGroup(
                  controller: _kitapAdiController,
                  textType: 'TextFormField',
                  textHeight: 50,
                  textWidth: MediaQuery.of(context).size.width,
                  hintText: 'Kitap Adı',
                  errorText: 'Kitap adı gerekli',
                ),
                TextAreaGroup(
                  controller: _yazarController,
                  textType: 'TextFormField',
                  textHeight: 50,
                  textWidth: MediaQuery.of(context).size.width,
                  hintText: 'Yazar Adı',
                  errorText: '',
                ),
                TextAreaGroup(
                  controller: _yayineviController,
                  textType: 'TextFormField',
                  textHeight: 50,
                  textWidth: MediaQuery.of(context).size.width,
                  hintText: 'Yayınevi',
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
                // TextFormField(
                //   controller: _kitapAdiController,
                //   decoration: InputDecoration(labelText: "Kitap Adı"),
                //   validator: (value) =>
                //       value!.isEmpty ? "Kitap adı gerekli" : null,
                // ),
                // TextFormField(
                //   controller: _yazarController,
                //   decoration: InputDecoration(labelText: "Yazar Adı"),
                // ),
                // TextFormField(
                //   controller: _yayineviController,
                //   decoration: InputDecoration(labelText: "Yayınevi"),
                // ),
                // TextFormField(
                //   controller: _isbnController,
                //   decoration: InputDecoration(labelText: "ISBN"),
                // ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _kitapEkle,
                  child: Text("Kitap Ekle"),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: kitapListesi.length,
            itemBuilder: (context, index) {
              final kitap = kitapListesi[index];
              return ListTile(
                leading: Icon(Icons.book),
                title: Text(kitap["kitapAdi"] ?? ""),
                subtitle: Text(
                  "Yazar: ${kitap["yazar"]}, Yayınevi: ${kitap["yayinevi"]}, ISBN: ${kitap["isbn"]}",
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
