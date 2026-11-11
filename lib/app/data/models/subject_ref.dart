import 'enums.dart';
import 'farmer.dart';
import 'processing_unit.dart';

/// Lightweight reference to the thing being audited (a farmer plot or a
/// processing unit). Notes, samples, photos and GPS screens work on this, so
/// they are shared between both flows.
class SubjectRef {
  const SubjectRef({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    this.products = const [],
  });

  final String id;
  final String name;
  final String subtitle;
  final UnitType type;
  final List<String> products;

  factory SubjectRef.farmer(Farmer f) => SubjectRef(
    id: f.id,
    name: f.name,
    subtitle: '${f.code} · Plot ${f.plot}',
    type: UnitType.production,
    products: f.crops.map((c) => c.name).toList(),
  );

  factory SubjectRef.processing(ProcessingUnit u) =>
      SubjectRef(id: u.id, name: u.name, subtitle: u.address, type: UnitType.processing, products: u.products);
}
