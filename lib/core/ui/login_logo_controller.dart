// lib/core/ui/login_logo_controller.dart
/*
هذا الملف مسؤول عن إدارة لوغو شاشة تسجيل الدخول.

قبل التعديل:
- كان اللوغو يُحفظ محليًا فقط على جهاز الأدمن داخل:
  ApplicationDocumentsDirectory/login_logo.png

بعد التعديل (مهم):
- ما زال يدعم اللوغو المحلي بالكامل (نفس الميزة بدون حذف)
- يدعم اللوغو العالمي من Firestore:
  ui/ui -> uiTheme.logoUrl
- أي هاتف يفتح التطبيق سيقرأ الرابط ويعرضه تلقائيًا
- عند تغيير اللوغو من شاشة الأدمن:
  1) نختار صورة
  2) نقصها
  3) نرفعها إلى Firebase Storage
  4) نكتب الرابط داخل Firestore (uiTheme.logoUrl)
  5) نحفظ نسخة محلية أيضًا (نفس الميزة القديمة)

ملاحظة مهمة:
- الرفع إلى Storage يحتاج صلاحيات Firestore + Storage للمستخدم المسجل.
*/

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'logo_crop_screen.dart';

class LoginLogoController extends ChangeNotifier {
  File? _logoFile;

  // 🔽 رابط اللوغو العالمي من Firestore
  String? _remoteLogoUrl;

  // 🔽 مراقبة تغييرات Firestore
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  // هذا يرجع ImageProvider جاهز للعرض
  // الأولوية:
  // 1) لوغو محلي (لأن الأدمن ممكن يعدل قبل الرفع)
  // 2) لوغو عالمي من Firestore
  // 3) null => يرجع Icon افتراضي في الواجهة
  ImageProvider? get logoImage {
    if (_logoFile != null) {
      return FileImage(_logoFile!);
    }

    if (_remoteLogoUrl != null && _remoteLogoUrl!.trim().isNotEmpty) {
      return NetworkImage(_remoteLogoUrl!.trim());
    }

    return null;
  }

  /// تشغيل مراقبة اللوغو من Firestore (Realtime)
  /// استدعاء واحد فقط يكفي (يفضل في main.dart)
  void startRemoteLogoListener() {
    // منع تكرار الاشتراك
    if (_sub != null) return;

    final ref = FirebaseFirestore.instance.collection('ui').doc('ui');

    _sub = ref.snapshots().listen((snap) {
      if (!snap.exists) {
        _remoteLogoUrl = null;
        notifyListeners();
        return;
      }

      final data = snap.data() ?? {};
      final uiTheme = (data['uiTheme'] as Map<String, dynamic>?) ?? {};
      final url = uiTheme['logoUrl']?.toString();

      // إذا نفس القيمة لا نعمل rebuild
      if (url == _remoteLogoUrl) return;

      _remoteLogoUrl = url;
      notifyListeners();
    });
  }

  /// إيقاف المراقبة (اختياري)
  void stopRemoteLogoListener() {
    _sub?.cancel();
    _sub = null;
  }

  /// هذه الدالة:
  /// - تختار صورة
  /// - تقصها
  /// - تحفظها محليًا
  /// - ترفعها إلى Firebase Storage
  /// - تكتب الرابط في Firestore (ui/ui -> uiTheme.logoUrl)
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

    // 1) حفظ محلي (نفس الميزة القديمة)
    final savedFile = await _saveLocally(croppedBytes);
    _logoFile = savedFile;
    notifyListeners();

    // 2) رفع إلى Storage + كتابة الرابط في Firestore
    final String url = await _uploadLogoToStorage(croppedBytes);
    await _saveLogoUrlToFirestore(url);

    // 3) تحديث الرابط الداخلي حتى يظهر فورًا بكل التطبيق
    _remoteLogoUrl = url;
    notifyListeners();
  }

  Future<File> _saveLocally(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/login_logo.png');
    return file.writeAsBytes(bytes, flush: true);
  }

  /// رفع الصورة إلى Firebase Storage
  /// ويعيد رابط تحميل مباشر (downloadURL)
  Future<String> _uploadLogoToStorage(Uint8List bytes) async {
    final storage = FirebaseStorage.instance;

    // نخلي مسار ثابت حتى كل رفع يستبدل القديم
    final ref = storage.ref().child('ui/login_logo.png');

    final metadata = SettableMetadata(
      contentType: 'image/png',
      cacheControl: 'no-cache',
    );

    await ref.putData(bytes, metadata);

    final url = await ref.getDownloadURL();
    return url;
  }

  /// حفظ رابط اللوغو داخل Firestore
  /// ui/ui -> uiTheme.logoUrl
  Future<void> _saveLogoUrlToFirestore(String url) async {
    final ref = FirebaseFirestore.instance.collection('ui').doc('ui');

    await ref.set(
      {
        'uiTheme': {
          'logoUrl': url,
        },
      },
      SetOptions(merge: true),
    );
  }

  Future<void> loadSavedLogo() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/login_logo.png');

    if (await file.exists()) {
      _logoFile = file;
      notifyListeners();
    }
  }

  /// حذف اللوغو:
  /// - يحذف المحلي
  /// - يحذف رابط Firestore
  /// - يحذف الملف من Storage
  Future<void> clearLogo() async {
    // 1) حذف محلي
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/login_logo.png');

    if (await file.exists()) {
      await file.delete();
    }

    _logoFile = null;
    notifyListeners();

    // 2) حذف من Firestore
    final ref = FirebaseFirestore.instance.collection('ui').doc('ui');
    await ref.set(
      {
        'uiTheme': {
          'logoUrl': FieldValue.delete(),
        },
      },
      SetOptions(merge: true),
    );

    // 3) حذف من Storage (اختياري لكن مهم حتى ما يبقى الملف)
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('ui/login_logo.png');
      await storageRef.delete();
    } catch (_) {
      // إذا الملف غير موجود لا نعتبره خطأ
    }

    _remoteLogoUrl = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopRemoteLogoListener();
    super.dispose();
  }
}
