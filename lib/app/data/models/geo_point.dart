class GeoPoint {
  const GeoPoint({required this.lat, required this.lng, required this.accuracy, required this.capturedAt});

  final double lat;
  final double lng;
  final double accuracy;
  final DateTime capturedAt;

  String get pretty => '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
}
