import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PolygonEditorScreen extends StatefulWidget {
  const PolygonEditorScreen({super.key});

  @override
  State<PolygonEditorScreen> createState() => _PolygonEditorScreenState();
}

class _PolygonEditorScreenState extends State<PolygonEditorScreen> {
  final List<LatLng> _points = [];
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
            onPressed: _saving ? null : _savePolygon,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _points.clear()),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(33.3152, 44.3661),
          initialZoom: 17,
          onTap: (_, p) {
            // إضافة نقطة عند اللمس
            setState(() => _points.add(p));
          },
        ),
        children: [
          // طبقة الخريطة (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.finger_app',
          ),

          // رسم المضلع
          if (_points.length >= 3)
            PolygonLayer(
              polygons: [
                Polygon(
                  points: _points,
                  color: Colors.orange.withValues(alpha: 0.3),
                  borderColor: Colors.orange,
                  borderStrokeWidth: 2,
                ),
              ],
            ),

          // نقاط الرسم
          MarkerLayer(
            markers: _points
                .map(
                  (p) => Marker(
                    point: p,
                    width: 12,
                    height: 12,
                    child: const Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.red,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _savePolygon() async {
    if (_points.length < 3) return;

    setState(() => _saving = true);

    final data = _points
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();

    await FirebaseFirestore.instance
        .collection('settings')
        .doc('attendance_area')
        .set({'polygon': data});

    if (mounted) Navigator.pop(context);
  }
}
