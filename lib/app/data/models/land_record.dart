import 'dart:math' as math;

/// One corner of a land boundary.
class LandPoint {
  const LandPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  String get pretty => '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
}

/// What the auditor records on the Point location screen: the land boundary
/// (polygon), a comment and photos.
class LandRecord {
  const LandRecord({this.boundary = const [], this.comment = '', this.imagePaths = const [], this.updatedAt});

  final List<LandPoint> boundary;
  final String comment;
  final List<String> imagePaths;
  final DateTime? updatedAt;

  static const empty = LandRecord();

  /// A closed area needs at least three corners.
  bool get hasBoundary => boundary.length >= 3;

  /// Area in hectares (0 until there are three corners).
  double get areaHa => hasBoundary ? polygonAreaM2(boundary) / 10000 : 0;

  LandPoint? get centre {
    if (boundary.isEmpty) return null;
    final lat = boundary.map((p) => p.lat).reduce((a, b) => a + b) / boundary.length;
    final lng = boundary.map((p) => p.lng).reduce((a, b) => a + b) / boundary.length;
    return LandPoint(lat, lng);
  }

  LandRecord copyWith({List<LandPoint>? boundary, String? comment, List<String>? imagePaths, DateTime? updatedAt}) =>
      LandRecord(
        boundary: boundary ?? this.boundary,
        comment: comment ?? this.comment,
        imagePaths: imagePaths ?? this.imagePaths,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Polygon area in m². Projects the corners onto a local flat plane around
  /// their centre (accurate to well under 1% for farm-sized plots), then uses
  /// the shoelace formula.
  static double polygonAreaM2(List<LandPoint> pts) {
    if (pts.length < 3) return 0;
    const earthRadius = 6371008.8;
    final lat0 = pts.map((p) => p.lat).reduce((a, b) => a + b) / pts.length * math.pi / 180;
    double x(LandPoint p) => earthRadius * p.lng * math.pi / 180 * math.cos(lat0);
    double y(LandPoint p) => earthRadius * p.lat * math.pi / 180;
    var sum = 0.0;
    for (var i = 0; i < pts.length; i++) {
      final a = pts[i];
      final b = pts[(i + 1) % pts.length];
      sum += x(a) * y(b) - x(b) * y(a);
    }
    return sum.abs() / 2;
  }
}
