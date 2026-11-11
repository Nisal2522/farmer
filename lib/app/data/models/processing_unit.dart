import 'geo_point.dart';

class ProcessingUnit {
  const ProcessingUnit({
    required this.id,
    required this.projectId,
    required this.name,
    required this.address,
    required this.cuid,
    required this.products,
    this.photoCount = 0,
    this.noteCount = 0,
    this.sampleCount = 0,
    this.location,
  });

  final String id;
  final String projectId;
  final String name;
  final String address;
  final String cuid;
  final List<String> products;
  final int photoCount;
  final int noteCount;
  final int sampleCount;
  final GeoPoint? location;

  ProcessingUnit copyWith({int? photoCount, int? noteCount, int? sampleCount, GeoPoint? location}) => ProcessingUnit(
    id: id,
    projectId: projectId,
    name: name,
    address: address,
    cuid: cuid,
    products: products,
    photoCount: photoCount ?? this.photoCount,
    noteCount: noteCount ?? this.noteCount,
    sampleCount: sampleCount ?? this.sampleCount,
    location: location ?? this.location,
  );
}
