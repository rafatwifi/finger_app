import 'package:geolocator/geolocator.dart';

class LocationService {
  // جلب الموقع الحالي (GPS)
  static Future<Position> getCurrentPosition() async {
    // طلب صلاحية الموقع
    await Geolocator.requestPermission();

    // جلب الموقع بدقة عالية
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
