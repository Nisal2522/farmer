import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/models.dart';
import '../theme/app_colors.dart';

/// Satellite imagery used for marking land (Esri World Imagery, no API key).
/// Needs internet; offline the map shows a plain background but the boundary
/// still draws.
// TODO(maps): for production use, register an ArcGIS / other imagery provider
// and pass its key here; Esri's terms require attribution (shown on the map).
class SatelliteTiles {
  SatelliteTiles._();

  static const attribution = 'Esri, Maxar, Earthstar Geographics';

  static TileLayer layer() => TileLayer(
    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    userAgentPackageName: 'com.cufarmer.cu_farmer',
    maxNativeZoom: 19,
  );

  /// Default view when nothing has been marked: Sri Lanka.
  static const defaultCentre = LatLng(7.8731, 80.7718);
}

LatLng toLatLng(LandPoint p) => LatLng(p.lat, p.lng);
LandPoint toLandPoint(LatLng p) => LandPoint(p.latitude, p.longitude);

/// Land boundary styling shared by the preview and the editor.
Polygon landPolygon(List<LandPoint> boundary) => Polygon(
  points: boundary.map(toLatLng).toList(),
  color: AppColors.mint.withValues(alpha: 0.38),
  borderColor: const Color(0xFFE5483B),
  borderStrokeWidth: 2.5,
);
