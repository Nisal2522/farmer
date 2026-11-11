import '../models/models.dart';
import 'audit_repository.dart';
import 'mock_data.dart';

/// In-memory implementation of [AuditRepository] with a small artificial
/// delay, so loading states behave like they will with the real API.
class MockAuditRepository implements AuditRepository {
  MockAuditRepository() {
    _seed();
  }

  final _projects = MockData.projects();
  final _farmers = MockData.farmers();
  final _processing = MockData.processingUnits();
  final _schedules = MockData.schedules();
  final _news = MockData.news();
  final _leaves = MockData.leaves();
  final _notes = <AuditNote>[];
  final _samples = <FieldSample>[];
  final _photos = <FieldPhoto>[];
  final _locations = <String, GeoPoint>{};
  final _dirtyProjects = <String>{};

  static const _latency = Duration(milliseconds: 350);
  Future<T> _delay<T>(T value) => Future.delayed(_latency, () => value);
  String _id(String prefix) => '$prefix${DateTime.now().microsecondsSinceEpoch}';

  void _seed() {
    final first = _farmers.first;
    final now = DateTime.now();
    _notes.addAll([
      AuditNote(
        id: 'note-seed-1',
        subjectId: first.id,
        category: 'Buffer zone / contamination prevention',
        type: NoteType.nonConformity,
        text:
            'Conventional vegetable plot on the eastern boundary with no physical barrier. '
            'Farmer was advised to plant a 3 m hedge row before the next season.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        synced: true,
      ),
      AuditNote(
        id: 'note-seed-2',
        subjectId: first.id,
        category: 'Farm records',
        type: NoteType.general,
        text: 'Harvest and sales records are up to date and match the yield estimate.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        synced: true,
      ),
    ]);
    _samples.add(
      FieldSample(
        id: 'sample-seed-1',
        subjectId: first.id,
        product: first.crops.first.name,
        reason: MockData.sampleReasons.first,
        locationDescription: MockData.sampleLocations.first,
        cropStatus: 'Harvesting stage',
        seals: const {
          SampleKind.lab: SealEntry(sealNo: '142321'),
          SampleKind.cu: SealEntry(sealNo: '139297'),
          SampleKind.client: SealEntry(sealNo: '590542'),
        },
        createdAt: now.subtract(const Duration(days: 1)),
        synced: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers

  Farmer _hydrate(Farmer f) => f.copyWith(
    noteCount: _notes.where((n) => n.subjectId == f.id).length,
    sampleCount: _samples.where((s) => s.subjectId == f.id).length,
    photoCount: _photos.where((p) => p.subjectId == f.id).length,
    location: _locations[f.id],
  );

  ProcessingUnit _hydrateUnit(ProcessingUnit u) => u.copyWith(
    noteCount: _notes.where((n) => n.subjectId == u.id).length,
    sampleCount: _samples.where((s) => s.subjectId == u.id).length,
    photoCount: _photos.where((p) => p.subjectId == u.id).length,
    location: _locations[u.id],
  );

  /// Flags the project that owns [subjectId] as having local changes.
  void _touch(String subjectId) {
    final farmer = _farmers.where((f) => f.id == subjectId).firstOrNull;
    final projectId = farmer?.projectId ?? _processing.where((u) => u.id == subjectId).firstOrNull?.projectId;
    if (projectId != null) _dirtyProjects.add(projectId);
  }

  AuditProject _withStats(AuditProject p) {
    final farmers = _farmers.where((f) => f.projectId == p.id);
    return p.copyWith(
      totalFarmers: farmers.length,
      auditedFarmers: farmers.where((f) => f.isAudited).length,
      syncState: _dirtyProjects.contains(p.id) ? SyncState.pendingUpload : p.syncState,
    );
  }

  // ---------------------------------------------------------------------------
  // Schedule & news

  @override
  Future<List<AuditSchedule>> fetchSchedules() => _delay(List.of(_schedules));

  @override
  Future<AuditSchedule> respondToSchedule(String id, {required bool accept, String? remark}) {
    final i = _schedules.indexWhere((s) => s.id == id);
    _schedules[i] = _schedules[i].copyWith(
      status: accept ? ScheduleStatus.confirmed : ScheduleStatus.rejected,
      remark: remark,
    );
    return _delay(_schedules[i]);
  }

  @override
  Future<List<NewsItem>> fetchNews() => _delay(List.of(_news));

  // ---------------------------------------------------------------------------
  // Projects & units

  @override
  Future<List<AuditProject>> fetchProjects() => _delay(_projects.map(_withStats).toList());

  @override
  Future<AuditProject> downloadProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final i = _projects.indexWhere((p) => p.id == projectId);
    _projects[i] = _projects[i].copyWith(syncState: SyncState.synced, lastSynced: DateTime.now());
    return _withStats(_projects[i]);
  }

  @override
  Future<List<ProductionUnit>> fetchProductionUnits(String projectId) {
    final byUnit = <String, List<Farmer>>{};
    for (final f in _farmers.where((f) => f.projectId == projectId)) {
      byUnit.putIfAbsent(f.unitCode, () => []).add(_hydrate(f));
    }
    final units =
        byUnit.entries
            .map(
              (e) => ProductionUnit(
                code: e.key,
                projectId: projectId,
                farmerCount: e.value.length,
                auditedCount: e.value.where((f) => f.isAudited).length,
                sampleCount: e.value.where((f) => f.hasSample).length,
              ),
            )
            .toList()
          ..sort((a, b) => a.code.compareTo(b.code));
    return _delay(units);
  }

  @override
  Future<List<ProcessingUnit>> fetchProcessingUnits(String projectId) =>
      _delay(_processing.where((u) => u.projectId == projectId).map(_hydrateUnit).toList());

  @override
  Future<ProcessingUnit> getProcessingUnit(String id) =>
      _delay(_hydrateUnit(_processing.firstWhere((u) => u.id == id)));

  // ---------------------------------------------------------------------------
  // Farmers

  @override
  Future<List<Farmer>> fetchFarmers(String projectId, String unitCode) =>
      _delay(_farmers.where((f) => f.projectId == projectId && f.unitCode == unitCode).map(_hydrate).toList());

  @override
  Future<Farmer> getFarmer(String id) => _delay(_hydrate(_farmers.firstWhere((f) => f.id == id)));

  @override
  Future<Farmer> setFarmerFlags(String id, {bool? audited, bool? selected}) {
    final i = _farmers.indexWhere((f) => f.id == id);
    _farmers[i] = _farmers[i].copyWith(isAudited: audited, isSelected: selected);
    _touch(id);
    return _delay(_hydrate(_farmers[i]));
  }

  // ---------------------------------------------------------------------------
  // Field records

  @override
  List<NoteCategory> get noteCategories => MockData.noteCategories;

  @override
  Future<List<AuditNote>> fetchNotes(String subjectId) => _delay(
    _notes.where((n) => n.subjectId == subjectId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<AuditNote> saveNote(AuditNote note) {
    final saved = AuditNote(
      id: _id('note'),
      subjectId: note.subjectId,
      category: note.category,
      subCategory: note.subCategory,
      type: note.type,
      text: note.text,
      imagePaths: note.imagePaths,
      createdAt: DateTime.now(),
    );
    _notes.add(saved);
    _touch(note.subjectId);
    return _delay(saved);
  }

  @override
  Future<List<FieldSample>> fetchSamples(String subjectId) => _delay(
    _samples.where((s) => s.subjectId == subjectId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<FieldSample> saveSample(FieldSample sample) {
    _samples.add(sample);
    _touch(sample.subjectId);
    return _delay(sample);
  }

  @override
  Future<List<FieldPhoto>> fetchPhotos(String subjectId) =>
      _delay(_photos.where((p) => p.subjectId == subjectId).toList());

  @override
  Future<FieldPhoto> savePhoto(FieldPhoto photo) {
    _photos.add(photo);
    _touch(photo.subjectId);
    return _delay(photo);
  }

  @override
  Future<GeoPoint?> getLocation(String subjectId) => _delay(_locations[subjectId]);

  @override
  Future<void> saveLocation(String subjectId, GeoPoint point) {
    _locations[subjectId] = point;
    _touch(subjectId);
    return _delay(null);
  }

  // ---------------------------------------------------------------------------
  // Leave

  @override
  Future<List<LeaveRequest>> fetchLeaves() => _delay(List.of(_leaves)..sort((a, b) => b.from.compareTo(a.from)));

  @override
  Future<LeaveRequest> applyLeave(LeaveRequest request) {
    _leaves.add(request);
    return _delay(request);
  }

  // ---------------------------------------------------------------------------
  // Sync

  @override
  Future<void> uploadPending() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    for (var i = 0; i < _notes.length; i++) {
      _notes[i] = _notes[i].markSynced();
    }
    for (var i = 0; i < _samples.length; i++) {
      _samples[i] = _samples[i].markSynced();
    }
    for (var i = 0; i < _projects.length; i++) {
      if (_dirtyProjects.contains(_projects[i].id)) {
        _projects[i] = _projects[i].copyWith(syncState: SyncState.synced, lastSynced: DateTime.now());
      }
    }
    _dirtyProjects.clear();
  }
}
