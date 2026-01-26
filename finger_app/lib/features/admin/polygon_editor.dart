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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPolygon();
  }

  Future<void> _loadPolygon() async {
    final snap = await FirebaseFirestore.instance
        .collection('settings')
        .doc('attendance_area')
        .get();

    if (snap.exists) {
      final data = snap.data();
      final List list = data?['polygon'] ?? [];
      for (final p in list) {
        _points.add(LatLng(p['lat'], p['lng']));
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Attendance Area'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _savePolygon),
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearPolygon),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _points.isNotEmpty
              ? _points.first
              : const LatLng(33.3152, 44.3661),
          zoom: 17,
        ),
        onMapCreated: (_) {},
        onTap: (p) {
          setState(() => _points.add(p));
        },
        polygons: {
          if (_points.length >= 3)
            Polygon(
              polygonId: const PolygonId('area'),
              points: _points,
              strokeColor: Colors.orange,
              fillColor: Colors.orange.withOpacity(0.3),
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
    if (_points.length < 3) return;

    final data = _points
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();

    await FirebaseFirestore.instance
        .collection('settings')
        .doc('attendance_area')
        .set({'polygon': data});

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Area saved')));
  }

  Future<void> _clearPolygon() async {
    setState(() => _points.clear());

    await FirebaseFirestore.instance
        .collection('settings')
        .doc('attendance_area')
        .delete();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Area cleared')));
  }
}
