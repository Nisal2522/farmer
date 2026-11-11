import 'geo_point.dart';

class Crop {
  const Crop({
    required this.name,
    required this.plants,
    required this.estYield,
    required this.realYield,
    required this.avgYield,
    required this.massBalance,
  });

  final String name;
  final double plants;
  final double estYield;
  final double realYield;
  final double avgYield;
  final double massBalance;
}

/// One field that may have changed since the previous audit.
class FieldChange {
  const FieldChange({required this.section, required this.label, required this.previous, required this.current});

  final String section;
  final String label;
  final String previous;
  final String current;

  bool get isChanged => previous != current;

  /// 1 when the value went up, -1 when down, 0 when equal or non-numeric.
  int get direction {
    final a = double.tryParse(previous);
    final b = double.tryParse(current);
    if (a == null || b == null || a == b) return 0;
    return b > a ? 1 : -1;
  }
}

class Farmer {
  const Farmer({
    required this.id,
    required this.projectId,
    required this.unitCode,
    required this.name,
    required this.code,
    required this.plot,
    required this.cuid,
    required this.address,
    required this.totalAreaHa,
    required this.certifications,
    required this.certificationDate,
    required this.fieldStatus,
    required this.harvestStatus,
    required this.crops,
    required this.changes,
    this.conversionDate,
    this.isNew = false,
    this.isChanged = false,
    this.isAudited = false,
    this.isSelected = false,
    this.photoCount = 0,
    this.noteCount = 0,
    this.sampleCount = 0,
    this.location,
  });

  final String id;
  final String projectId;
  final String unitCode;
  final String name;
  final String code;
  final String plot;
  final String cuid;
  final String address;
  final double totalAreaHa;
  final List<String> certifications;
  final DateTime certificationDate;
  final DateTime? conversionDate;
  final String fieldStatus;
  final String harvestStatus;
  final List<Crop> crops;
  final List<FieldChange> changes;
  final bool isNew;
  final bool isChanged;
  final bool isAudited;
  final bool isSelected;
  final int photoCount;
  final int noteCount;
  final int sampleCount;
  final GeoPoint? location;

  int get changedFieldCount => changes.where((c) => c.isChanged).length;
  bool get hasSample => sampleCount > 0;

  Farmer copyWith({
    bool? isAudited,
    bool? isSelected,
    int? photoCount,
    int? noteCount,
    int? sampleCount,
    GeoPoint? location,
  }) => Farmer(
    id: id,
    projectId: projectId,
    unitCode: unitCode,
    name: name,
    code: code,
    plot: plot,
    cuid: cuid,
    address: address,
    totalAreaHa: totalAreaHa,
    certifications: certifications,
    certificationDate: certificationDate,
    conversionDate: conversionDate,
    fieldStatus: fieldStatus,
    harvestStatus: harvestStatus,
    crops: crops,
    changes: changes,
    isNew: isNew,
    isChanged: isChanged,
    isAudited: isAudited ?? this.isAudited,
    isSelected: isSelected ?? this.isSelected,
    photoCount: photoCount ?? this.photoCount,
    noteCount: noteCount ?? this.noteCount,
    sampleCount: sampleCount ?? this.sampleCount,
    location: location ?? this.location,
  );
}
