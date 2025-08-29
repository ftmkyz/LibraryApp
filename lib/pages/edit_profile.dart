import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  // ignore: use_super_parameters
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _imageFile;
  String? _base64Image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      final bytes = await pickedFile.readAsBytes();
      _base64Image = base64Encode(bytes);
    }
  }

  Future<void> _saveProfileImage() async {
    if (_base64Image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', _base64Image!);
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Profile picture saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
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
                    onBackgroundImageError: (_, __) {},
                    child: null,
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
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to homepage
              },
            ),
            ListTile(
              title: Text(isTurkish ? "Alınacak listesi" : "Wishlist"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to homepage
              },
            ),
            ListTile(
              title: Text(isTurkish ? "Profili Düzenle" : "Edit Profile"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(_imageFile!),
                  )
                : CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Choose Picture'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProfileImage, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
