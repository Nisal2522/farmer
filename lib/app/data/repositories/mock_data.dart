import 'dart:math';

import '../models/models.dart';

/// Deterministic sample data so the app is fully usable before the backend
/// is connected.
class MockData {
  MockData._();

  static var _rnd = Random(7);
  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static const _names = [
    'M.W.J. Bandara',
    'U.W. Senarathne',
    'K.P. Dissanayake',
    'R.M. Herath',
    'S.A. Perera',
    'D.M. Wijesinghe',
    'H.K. Gunawardena',
    'W.A. Rathnayake',
    'N.G. Jayawardena',
    'T.M. Ekanayake',
    'A.L. Fernando',
    'P.R. Kumara',
    'G.D. Silva',
    'B.M. Rajapaksha',
    'J.K. Weerasinghe',
    'C.S. Abeysekara',
    'L.P. Samarakoon',
    'E.R. Wickramasinghe',
    'I.M. Karunaratne',
    'V.S. Amarasinghe',
  ];

  static const _villages = [
    'Galaha',
    'Deltota',
    'Hantana',
    'Pussellawa',
    'Matale',
    'Ukuwela',
    'Rattota',
    'Elkaduwa',
    'Wattegama',
    'Panwila',
  ];

  static const _cropsByProject = {
    'p1': ['Tea', 'Curry leaves', 'Banana', 'Clove buds', 'Pepper'],
    'p2': ['Pepper', 'Cinnamon', 'Banana', 'Mango'],
    'p3': ['Cinnamon', 'Pepper', 'Clove buds', 'Nutmeg'],
    'p4': ['Coconut', 'Mango', 'Banana', 'Moringa'],
    'p5': ['Tea', 'Pepper', 'Cardamom', 'Banana'],
    'p6': ['Cinnamon', 'Pepper', 'Coconut', 'Nutmeg'],
  };

  /// Downloaded and not-yet-downloaded projects alternate, so the list shows
  /// both states (and the download action) throughout.
  static List<AuditProject> projects() => [
    AuditProject(
      id: 'p1',
      name: 'Highland Tea Estates',
      auditNo: 'ADT 579026',
      standard: 'EU Organic · NOP',
      syncState: SyncState.synced,
      lastSynced: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    const AuditProject(
      id: 'p3',
      name: 'Spice Coast Growers',
      auditNo: 'ADT 304118',
      standard: 'NOP · Naturland',
      syncState: SyncState.notDownloaded,
    ),
    AuditProject(
      id: 'p2',
      name: 'Green Valley Organics',
      auditNo: 'ADT 616415',
      standard: 'EU Organic · JAS',
      syncState: SyncState.synced,
      lastSynced: DateTime.now().subtract(const Duration(days: 1)),
    ),
    const AuditProject(
      id: 'p5',
      name: 'Uva Hills Smallholders',
      auditNo: 'ADT 488250',
      standard: 'EU Organic · Fairtrade',
      syncState: SyncState.notDownloaded,
    ),
    AuditProject(
      id: 'p4',
      name: 'Coconut Belt Cooperative',
      auditNo: 'ADT 271903',
      standard: 'EU Organic',
      syncState: SyncState.synced,
      lastSynced: DateTime.now().subtract(const Duration(days: 4)),
    ),
    const AuditProject(
      id: 'p6',
      name: 'Ruhuna Cinnamon Partners',
      auditNo: 'ADT 552917',
      standard: 'NOP · EU Organic',
      syncState: SyncState.notDownloaded,
    ),
  ];

  static List<Farmer> farmers() {
    _rnd = Random(7); // same data every time the repository is created
    final list = <Farmer>[];
    const unitsPerProject = {'p1': 9, 'p2': 6, 'p3': 5, 'p4': 4, 'p5': 4, 'p6': 3};
    var cuid = 1;
    for (final entry in unitsPerProject.entries) {
      final projectId = entry.key;
      final crops = _cropsByProject[projectId]!;
      for (var u = 1; u <= entry.value; u++) {
        final unitCode = 'F${u.toString().padLeft(2, '0')}';
        final farmerCount = 6 + _rnd.nextInt(8);
        for (var f = 1; f <= farmerCount; f++) {
          final name = _names[_rnd.nextInt(_names.length)];
          final plots = 1 + (_rnd.nextDouble() < 0.3 ? _rnd.nextInt(3) : 0);
          final code = 'F$u/1/${(f * 3).toString().padLeft(3, '0')}';
          final village = _villages[_rnd.nextInt(_villages.length)];
          for (var p = 0; p < plots; p++) {
            final plot = String.fromCharCode(65 + p);
            final changed = _rnd.nextDouble() < 0.45;
            final farmerCrops = _crops(crops);
            final prevArea = 0.4 + _rnd.nextDouble() * 1.6;
            final area = changed && _rnd.nextBool() ? prevArea + 0.25 + _rnd.nextDouble() : prevArea;
            list.add(
              Farmer(
                id: '$projectId-$unitCode-$f$plot',
                projectId: projectId,
                unitCode: unitCode,
                name: name,
                code: code,
                plot: plot,
                cuid: '${cuid++}',
                address: village,
                totalAreaHa: double.parse(area.toStringAsFixed(2)),
                certifications: const ['NOP', 'EU', 'JAS', 'Naturland'].take(2 + _rnd.nextInt(3)).toList(),
                certificationDate: DateTime(2015 + _rnd.nextInt(8), 1 + _rnd.nextInt(12), 1),
                conversionDate: _rnd.nextBool() ? DateTime(2014 + _rnd.nextInt(6), 6, 6) : null,
                fieldStatus: _rnd.nextDouble() < 0.8 ? 'ORG' : 'IC 2',
                harvestStatus: _rnd.nextDouble() < 0.75 ? 'ORG' : 'IC 1',
                crops: farmerCrops,
                changes: _changes(prevArea, area, farmerCrops, changed),
                isNew: _rnd.nextDouble() < 0.08,
                isChanged: changed,
                isAudited: _rnd.nextDouble() < 0.22,
                isSelected: _rnd.nextDouble() < 0.12,
              ),
            );
          }
        }
      }
    }
    return list;
  }

  static List<Crop> _crops(List<String> pool) {
    final shuffled = [...pool]..shuffle(_rnd);
    return shuffled.take(2 + _rnd.nextInt(pool.length - 1)).map((name) {
      final plants = (10 + _rnd.nextInt(800)).toDouble();
      final est = plants * (5 + _rnd.nextInt(40));
      final real = _rnd.nextBool() ? est * (0.6 + _rnd.nextDouble() * 0.5) : 0.0;
      return Crop(
        name: name,
        plants: plants,
        estYield: est,
        realYield: double.parse(real.toStringAsFixed(1)),
        avgYield: double.parse(((est + real) / 2).toStringAsFixed(1)),
        massBalance: double.parse((est - real).toStringAsFixed(1)),
      );
    }).toList();
  }

  static List<FieldChange> _changes(double prevArea, double area, List<Crop> crops, bool changed) {
    String n(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    final out = <FieldChange>[
      FieldChange(
        section: 'Basic details',
        label: 'Total area (ha)',
        previous: prevArea.toStringAsFixed(2),
        current: area.toStringAsFixed(2),
      ),
      FieldChange(
        section: 'Basic details',
        label: 'USDA harvest status',
        previous: changed && _rnd.nextBool() ? 'IC 1' : 'ORG',
        current: 'ORG',
      ),
    ];
    for (final c in crops) {
      final plantsBefore = changed && _rnd.nextBool()
          ? (c.plants * (0.6 + _rnd.nextDouble() * 0.3)).roundToDouble()
          : c.plants;
      final yieldBefore = changed && _rnd.nextBool()
          ? (c.estYield * (0.7 + _rnd.nextDouble() * 0.5)).roundToDouble()
          : c.estYield;
      out
        ..add(FieldChange(section: c.name, label: 'No. of plants', previous: n(plantsBefore), current: n(c.plants)))
        ..add(
          FieldChange(section: c.name, label: 'Est. yield (kg/yr)', previous: n(yieldBefore), current: n(c.estYield)),
        )
        ..add(FieldChange(section: c.name, label: 'Real yield (kg/yr)', previous: '0', current: n(c.realYield)));
    }
    return out;
  }

  static List<ProcessingUnit> processingUnits() {
    const data = {
      'p1': [
        ('Tea Factory – Line 2', 'No. 241A, Ambathale Road, Mulleriyawa', ['Green tea', 'Black tea BOP', 'Tea dust']),
        ('Central Drying Facility', '50/12, Attidiya Road, Kawdana', ['Dried curry leaves', 'Clove buds']),
      ],
      'p2': [
        ('Cinnamon Grinding Unit', 'Udahamulla North', ['Cinnamon powder', 'Cinnamon quills']),
        ('Spice Packing Centre', '679/18 Walpita Road, Polhena', ['Black pepper', 'White pepper']),
        ('Fruit Processing Unit', '103/6 Frasawatte Road, Mattakkuliya', ['Dried mango', 'Banana chips']),
      ],
      'p3': [
        ('Coastal Spice Mill', 'Galle Road, Ambalangoda', ['Cinnamon oil', 'Nutmeg powder']),
      ],
      'p4': [
        (
          'Coconut Processing Unit',
          'Kurunegala Road, Kuliyapitiya',
          ['Coconut sugar crystal', 'Coconut syrup', 'Virgin coconut oil'],
        ),
        ('Moringa Drying Shed', 'The Junkyard, Wilfred Road', ['Dried moringa flower', 'Dried moringa seeds']),
      ],
    };
    var i = 0;
    return [
      for (final e in data.entries)
        for (final u in e.value)
          ProcessingUnit(
            id: 'pu${++i}',
            projectId: e.key,
            name: u.$1,
            address: u.$2,
            cuid: '${366629800 + i * 7}',
            products: u.$3,
          ),
    ];
  }

  static List<AuditSchedule> schedules() {
    final t = _today;
    return [
      AuditSchedule(
        id: 's1',
        start: t,
        end: t.add(const Duration(days: 1)),
        company: 'Highland Tea Estates',
        auditType: 'EU Audit · Surveillance',
        location: 'Kandy',
        status: ScheduleStatus.confirmed,
      ),
      AuditSchedule(
        id: 's2',
        start: t.add(const Duration(days: 3)),
        end: t.add(const Duration(days: 4)),
        company: 'Green Valley Organics',
        auditType: 'EU Audit · Initial',
        location: 'Matale',
        status: ScheduleStatus.pending,
      ),
      AuditSchedule(
        id: 's3',
        start: t.add(const Duration(days: 6)),
        end: t.add(const Duration(days: 6)),
        company: 'Ceylon Herbals (Pvt) Ltd',
        auditType: 'EU Audit · Unannounced',
        location: 'Kurunegala',
        status: ScheduleStatus.rejected,
        remark: 'Clashes with the Spice Coast audit — please reassign.',
      ),
      AuditSchedule(
        id: 's4',
        start: t.add(const Duration(days: 9)),
        end: t.add(const Duration(days: 10)),
        company: 'Spice Coast Growers',
        auditType: 'NOP Audit · Initial',
        location: 'Galle',
        status: ScheduleStatus.pending,
      ),
      AuditSchedule(
        id: 's5',
        start: t.add(const Duration(days: 16)),
        end: t.add(const Duration(days: 18)),
        company: 'Coconut Belt Cooperative',
        auditType: 'EU Audit · Surveillance',
        location: 'Kuliyapitiya',
        status: ScheduleStatus.pending,
      ),
      AuditSchedule(
        id: 's6',
        start: t.subtract(const Duration(days: 12)),
        end: t.subtract(const Duration(days: 11)),
        company: 'Lanka Fruit Exporters',
        auditType: 'JAS Audit · Initial',
        location: 'Anuradhapura',
        status: ScheduleStatus.confirmed,
      ),
    ];
  }

  static List<NewsItem> news() {
    final t = DateTime.now();
    return [
      NewsItem(
        id: 'n1',
        title: 'Updated sampling procedure for 2026',
        tag: 'Procedure',
        author: 'Quality Team',
        date: t.subtract(const Duration(hours: 5)),
        body:
            'From this month every field sample must be split into equal parts for the lab, '
            'CU and client, each sealed and photographed with its seal number visible. '
            'Draw a sampling map for every sample, showing the buffer zone and the exact '
            'location where the sample was taken.\n\nAudits uploaded without seal photos will '
            'be returned for correction.',
      ),
      NewsItem(
        id: 'n2',
        title: 'Upload audit data within 48 hours',
        tag: 'Reminder',
        author: 'Admin',
        date: t.subtract(const Duration(days: 2)),
        body:
            'Please sync all audit notes, samples and photos within 48 hours of finishing '
            'an audit. The app keeps working offline, so you can sync as soon as you are back in coverage.',
      ),
      NewsItem(
        id: 'n3',
        title: 'New non-conformity note categories',
        tag: 'Release',
        author: 'Certification Desk',
        date: t.subtract(const Duration(days: 6)),
        body:
            'Soil inputs now has three sub-categories: input receiving/purchasing evidence, '
            'input storage, and input records with input mass balance. Use them to file NC notes accurately.',
      ),
      NewsItem(
        id: 'n4',
        title: 'Office closed on Poya day',
        tag: 'Notice',
        author: 'HR',
        date: t.subtract(const Duration(days: 11)),
        body:
            'The head office will be closed on the upcoming Poya day. Field audits scheduled '
            'for that day go ahead unless your coordinator tells you otherwise.',
      ),
    ];
  }

  static List<LeaveRequest> leaves() {
    final t = _today;
    return [
      LeaveRequest(
        id: 'l1',
        type: LeaveType.annual,
        from: t.add(const Duration(days: 21)),
        to: t.add(const Duration(days: 23)),
        status: LeaveStatus.pending,
        reason: 'Family trip',
      ),
      LeaveRequest(
        id: 'l2',
        type: LeaveType.casual,
        from: t.subtract(const Duration(days: 18)),
        to: t.subtract(const Duration(days: 18)),
        status: LeaveStatus.approved,
        halfDay: true,
        approvedBy: 'Admin',
      ),
      LeaveRequest(
        id: 'l3',
        type: LeaveType.sick,
        from: t.subtract(const Duration(days: 40)),
        to: t.subtract(const Duration(days: 39)),
        status: LeaveStatus.approved,
        approvedBy: 'Admin',
      ),
    ];
  }

  static const noteCategories = [
    NoteCategory('Farm map'),
    NoteCategory('Farm records'),
    NoteCategory('Farmer list, yield estimation, products'),
    NoteCategory('Buffer zone / contamination prevention'),
    NoteCategory('Cultivation practices'),
    NoteCategory('Soil inputs', [
      'Input receiving / purchasing evidence',
      'Input storage',
      'Input records and input mass balance',
    ]),
    NoteCategory('Crop pest, weed and disease management'),
    NoteCategory('Planting materials'),
    NoteCategory('Farm storage'),
    NoteCategory('Post-harvest activities and product storage'),
    NoteCategory('Biodiversity conservation'),
  ];

  static const sampleReasons = [
    'Random sampling',
    'Risk-based sampling',
    'Conversion period recognition',
    'Complaint / investigation',
  ];

  static const sampleLocations = ['Near the buffer zone', 'Middle of the farm', 'Near risky crop', 'Other'];

  static const cropStatuses = ['Just after planting', 'Vegetative', 'Flowering', 'Harvesting stage', 'Post-harvest'];
}
