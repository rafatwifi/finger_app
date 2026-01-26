class PolygonUtils {
  // فحص هل النقطة داخل مضلع (Polygon) باستخدام خوارزمية Ray Casting
  // النقطة: (lat, lng)
  // المضلع: قائمة نقاط [[lat,lng], [lat,lng], ...] مرتبة حول الحدود
  static bool isPointInsidePolygon({
    required double lat,
    required double lng,
    required List<List<double>> polygon,
  }) {
    // إذا عدد نقاط المضلع أقل من 3 → مستحيل يكون مضلع
    if (polygon.length < 3) return false;

    bool inside = false;

    // نمر على كل ضلع (نقطة i مع النقطة j السابقة)
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final yi = polygon[i][0]; // lat للنقطة i
      final xi = polygon[i][1]; // lng للنقطة i
      final yj = polygon[j][0]; // lat للنقطة j
      final xj = polygon[j][1]; // lng للنقطة j

      // هل خط الشعاع من النقطة يقطع الضلع؟
      final intersects =
          ((yi > lat) != (yj > lat)) &&
          (lng <
              (xj - xi) * (lat - yi) / ((yj - yi) == 0 ? 1e-12 : (yj - yi)) +
                  xi);

      // إذا قطع → نقلب الحالة (داخل/خارج)
      if (intersects) inside = !inside;
    }

    return inside;
  }
}
