import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PolygonEditorScreen extends StatefulWidget {
  const PolygonEditorScreen({super.key});

  @override
  State<PolygonEditorScreen> createState() => _PolygonEditorScreenState();
}

class _PolygonEditorScreenState extends State<PolygonEditorScreen> {
  // نقاط المضلع اللي يرسمها الأدمن
  final List<LatLng> _points = [];

  // نحتفظ بالكونترولر حتى نقدر نحرك/نزوّم لاحقاً (حاليا مو ضروري)
  GoogleMapController? _map;

  // حالة تحميل أثناء الحفظ حتى ما يضغط حفظ أكثر من مرة
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Draw Area'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _saving ? null : _savePolygon, // حفظ المضلع
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // مسح النقاط الحالية (رجوع للرسم من جديد)
              setState(() => _points.clear());
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(33.3152, 44.3661),
          zoom: 17,
        ),
        onMapCreated: (c) => _map = c, // نخزن الكونترولر حتى يصير "مستخدم"
        onTap: (p) {
          // إضافة نقطة للمضلع عند اللمس
          setState(() => _points.add(p));
        },
        polygons: {
          if (_points.length >= 3)
            Polygon(
              polygonId: const PolygonId('attendance_area'),
              points: _points,
              strokeColor: Colors.orange,
              fillColor: Colors.orange.withValues(alpha: 0.30),
              strokeWidth: 2,
            ),
        },
        markers: _points
            .map(
              (p) => Marker(
                markerId: MarkerId('${p.latitude},${p.longitude}'),
                position: p,
              ),
            )
            .toSet(),
      ),
    );
  }

  Future<void> _savePolygon() async {
    // يمنع الحفظ إذا النقاط أقل من 3
    if (_points.length < 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ارسم 3 نقاط على الأقل')));
      return;
    }

    setState(() => _saving = true);

    try {
      // تحويل النقاط لصيغة تخزين داخل Firestore
      final data = _points
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList();

      // نخزن المضلع بالإعدادات
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('attendance_area')
          .set({'polygon': data});

      if (!mounted) return;
      Navigator.pop(context); // رجوع بعد الحفظ
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ بالحفظ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
