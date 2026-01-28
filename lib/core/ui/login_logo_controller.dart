/*
هذا الملف مسؤول عن إدارة لوغو شاشة تسجيل الدخول.

الوظائف:
- اختيار صورة من الجهاز
- فتح شاشة Crop مخصصة داخل Flutter (crop_your_image)
- تنفيذ القص بزر ✔️ سفلي واضح
- حفظ الصورة محليًا
- توفير ImageProvider جاهز للعرض

تم حذف UCrop نهائيًا.
*/

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'logo_crop_screen.dart';

class LoginLogoController extends ChangeNotifier {
  File? _logoFile;

  ImageProvider? get logoImage {
    if (_logoFile == null) return null;
    return FileImage(_logoFile!);
  }

  Future<void> pickAndCropLogo(BuildContext context) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();

    final Uint8List? croppedBytes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogoCropScreen(imageData: imageBytes),
      ),
    );

    if (croppedBytes == null) return;

    final savedFile = await _saveLocally(croppedBytes);
    _logoFile = savedFile;
    notifyListeners();
  }

  Future<File> _saveLocally(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/login_logo.png');
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> loadSavedLogo() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/login_logo.png');

    if (await file.exists()) {
      _logoFile = file;
      notifyListeners();
    }
  }

  Future<void> clearLogo() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/login_logo.png');

    if (await file.exists()) {
      await file.delete();
    }

    _logoFile = null;
    notifyListeners();
  }
}
