import '../models/models.dart';

/// Single entry point the UI uses for data.
///
/// [MockAuditRepository] implements this with in-memory sample data. When the
/// backend is ready, add an `ApiAuditRepository` that uses `ApiClient` and
/// register it in `main.dart` instead — no controller or view has to change.
abstract class AuditRepository {
  // Schedule & news
  Future<List<AuditSchedule>> fetchSchedules();
  Future<AuditSchedule> respondToSchedule(String id, {required bool accept, String? remark});
  Future<List<NewsItem>> fetchNews();

  // Projects & units
  Future<List<AuditProject>> fetchProjects();
  Future<AuditProject> downloadProject(String projectId);
  Future<List<ProductionUnit>> fetchProductionUnits(String projectId);
  Future<List<ProcessingUnit>> fetchProcessingUnits(String projectId);
  Future<ProcessingUnit> getProcessingUnit(String id);

  // Farmers
  Future<List<Farmer>> fetchFarmers(String projectId, String unitCode);
  Future<Farmer> getFarmer(String id);
  Future<Farmer> setFarmerFlags(String id, {bool? audited, bool? selected});

  // Field records (shared by farmers and processing units)
  List<NoteCategory> get noteCategories;
  Future<List<AuditNote>> fetchNotes(String subjectId);
  Future<AuditNote> saveNote(AuditNote note);
  Future<List<FieldSample>> fetchSamples(String subjectId);
  Future<FieldSample> saveSample(FieldSample sample);
  Future<List<FieldPhoto>> fetchPhotos(String subjectId);
  Future<FieldPhoto> savePhoto(FieldPhoto photo);
  Future<GeoPoint?> getLocation(String subjectId);
  Future<void> saveLocation(String subjectId, GeoPoint point);

  // Leave
  Future<List<LeaveRequest>> fetchLeaves();
  Future<LeaveRequest> applyLeave(LeaveRequest request);

  // Sync
  Future<void> uploadPending();
}
