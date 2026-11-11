import 'dart:typed_data';

import 'enums.dart';

class NoteCategory {
  const NoteCategory(this.title, [this.subCategories = const []]);

  final String title;
  final List<String> subCategories;
}

class AuditNote {
  const AuditNote({
    required this.id,
    required this.subjectId,
    required this.category,
    required this.type,
    required this.text,
    required this.createdAt,
    this.subCategory,
    this.imagePaths = const [],
    this.synced = false,
  });

  final String id;
  final String subjectId;
  final String category;
  final String? subCategory;
  final NoteType type;
  final String text;
  final List<String> imagePaths;
  final DateTime createdAt;
  final bool synced;

  String get categoryPath => subCategory == null ? category : '$category › $subCategory';

  AuditNote markSynced() => AuditNote(
    id: id,
    subjectId: subjectId,
    category: category,
    subCategory: subCategory,
    type: type,
    text: text,
    imagePaths: imagePaths,
    createdAt: createdAt,
    synced: true,
  );
}

class SealEntry {
  const SealEntry({required this.sealNo, this.imagePath});

  final String sealNo;
  final String? imagePath;
}

class FieldSample {
  const FieldSample({
    required this.id,
    required this.subjectId,
    required this.product,
    required this.reason,
    required this.locationDescription,
    required this.cropStatus,
    required this.seals,
    required this.createdAt,
    this.technique = '',
    this.mapPng,
    this.synced = false,
  });

  final String id;
  final String subjectId;
  final String product;
  final String reason;
  final String locationDescription;
  final String cropStatus;
  final String technique;
  final Uint8List? mapPng;
  final Map<SampleKind, SealEntry> seals;
  final DateTime createdAt;
  final bool synced;

  FieldSample markSynced() => FieldSample(
    id: id,
    subjectId: subjectId,
    product: product,
    reason: reason,
    locationDescription: locationDescription,
    cropStatus: cropStatus,
    technique: technique,
    mapPng: mapPng,
    seals: seals,
    createdAt: createdAt,
    synced: true,
  );
}

class FieldPhoto {
  const FieldPhoto({
    required this.id,
    required this.subjectId,
    required this.path,
    required this.kind,
    required this.createdAt,
  });

  final String id;
  final String subjectId;
  final String path;
  final PhotoKind kind;
  final DateTime createdAt;
}

class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.date,
    this.tag = 'Update',
  });

  final String id;
  final String title;
  final String body;
  final String author;
  final DateTime date;
  final String tag;
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.status,
    this.halfDay = false,
    this.reason = '',
    this.approvedBy,
  });

  final String id;
  final LeaveType type;
  final DateTime from;
  final DateTime to;
  final LeaveStatus status;
  final bool halfDay;
  final String reason;
  final String? approvedBy;

  double get days => halfDay ? 0.5 : (to.difference(from).inDays + 1).toDouble();
}
