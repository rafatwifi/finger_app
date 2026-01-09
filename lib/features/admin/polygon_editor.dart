import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PolygonEditorScreen extends StatefulWidget {
  const PolygonEditorScreen({super.key});

  @override
  State<PolygonEditorScreen> createState() => _PolygonEditorScreenState();
}

class _PolygonEditorScreenState extends State<PolygonEditorScreen> {
  final List<LatLng> _points = [];
  GoogleMapController? _map;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Draw Area'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _savePolygon),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(33.3152, 44.3661),
          zoom: 17,
        ),
        onMapCreated: (c) => _map = c,
        onTap: (p) {
          // إضافة نقطة عند الضغط
          setState(() => _points.add(p));
        },
        polygons: {
          if (_points.length >= 3)
            Polygon(
              polygonId: const PolygonId('area'),
              points: _points,
              strokeColor: Colors.orange,
              fillColor: Colors.orange.withValues(alpha: 0.3),
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

  // حفظ المضلع في Firestore
  Future<void> _savePolygon() async {
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
