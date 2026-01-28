/*
هذا الملف يمثل شاشة اقتصاص مخصصة للوغو باستخدام crop_your_image.

الوظائف:
- عرض الصورة مع إمكانية Zoom / Pan
- قص بنسبة 1:1
- أزرار ✔ و ❌ ثابتة أسفل الشاشة
- إرجاع Uint8List بعد القص
*/

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

class LogoCropScreen extends StatefulWidget {
  final Uint8List imageData;

  const LogoCropScreen({
    super.key,
    required this.imageData,
  });

  @override
  State<LogoCropScreen> createState() => _LogoCropScreenState();
}

class _LogoCropScreenState extends State<LogoCropScreen> {
  final CropController _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Crop Logo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageData,
              controller: _controller,
              aspectRatio: 1,
              withCircleUi: false,
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.6),
              onCropped: (Uint8List croppedData) {
                Navigator.pop(context, croppedData);
              },
            ),
          ),

          // أزرار التحكم
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _cropping ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cropping
                          ? null
                          : () {
                              setState(() => _cropping = true);
                              _controller.crop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('تم'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
