import 'package:get/get.dart';

import '../modules/audits/audits_controller.dart';
import '../modules/audits/audits_view.dart';
import '../modules/auth/login_controller.dart';
import '../modules/auth/login_view.dart';
import '../modules/farmer/farmer_changes_controller.dart';
import '../modules/farmer/farmer_changes_view.dart';
import '../modules/farmer/farmer_controller.dart';
import '../modules/farmer/farmer_details_view.dart';
import '../modules/farmer/farmer_view.dart';
import '../modules/farmers/farmers_controller.dart';
import '../modules/farmers/farmers_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/leave/leave_apply_controller.dart';
import '../modules/leave/leave_apply_view.dart';
import '../modules/leave/leave_controller.dart';
import '../modules/leave/leave_view.dart';
import '../modules/location/location_controller.dart';
import '../modules/location/location_view.dart';
import '../modules/location/map_editor_controller.dart';
import '../modules/location/map_editor_view.dart';
import '../modules/news/news_controller.dart';
import '../modules/news/news_detail_view.dart';
import '../modules/news/news_view.dart';
import '../modules/notes/note_editor_controller.dart';
import '../modules/notes/note_editor_view.dart';
import '../modules/notes/notes_controller.dart';
import '../modules/notes/notes_view.dart';
import '../modules/photos/photos_controller.dart';
import '../modules/photos/photos_view.dart';
import '../modules/processing/processing_unit_controller.dart';
import '../modules/processing/processing_unit_view.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/profile/profile_view.dart';
import '../modules/samples/sample_form_controller.dart';
import '../modules/samples/sample_form_view.dart';
import '../modules/samples/samples_controller.dart';
import '../modules/samples/samples_view.dart';
import '../modules/scanner/scanner_view.dart';
import '../modules/schedule/schedule_controller.dart';
import '../modules/schedule/schedule_view.dart';
import '../modules/shell/shell_controller.dart';
import '../modules/shell/shell_view.dart';
import '../modules/sketch/sketch_controller.dart';
import '../modules/sketch/sketch_view.dart';
import '../modules/units/project_units_controller.dart';
import '../modules/units/project_units_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  /// The app always opens on the Login page after the launch screen.
  static const initial = Routes.login;

  static final pages = <GetPage<dynamic>>[
    GetPage(name: Routes.login, page: () => const LoginView(), binding: BindingsBuilder.put(() => LoginController())),
    GetPage(
      name: Routes.shell,
      page: () => const ShellView(),
      binding: BindingsBuilder(() {
        Get
          ..put(ShellController())
          ..put(HomeController())
          ..put(AuditsController())
          ..put(ScheduleController())
          ..put(ProfileController());
      }),
    ),
    // Sections opened from Home; controllers come from the shell binding above.
    GetPage(name: Routes.audits, page: () => const SectionPage(child: AuditsView())),
    GetPage(name: Routes.schedule, page: () => const SectionPage(child: ScheduleView())),
    GetPage(name: Routes.profile, page: () => const SectionPage(child: ProfileView())),
    GetPage(
      name: Routes.projectUnits,
      page: () => const ProjectUnitsView(),
      binding: BindingsBuilder.put(() => ProjectUnitsController()),
    ),
    GetPage(
      name: Routes.farmers,
      page: () => const FarmersView(),
      binding: BindingsBuilder.put(() => FarmersController()),
    ),
    GetPage(
      name: Routes.farmer,
      page: () => const FarmerView(),
      binding: BindingsBuilder.put(() => FarmerController()),
    ),
    GetPage(name: Routes.farmerDetails, page: () => const FarmerDetailsView()),
    GetPage(
      name: Routes.farmerChanges,
      page: () => const FarmerChangesView(),
      binding: BindingsBuilder.put(() => FarmerChangesController()),
    ),
    GetPage(
      name: Routes.processingUnit,
      page: () => const ProcessingUnitView(),
      binding: BindingsBuilder.put(() => ProcessingUnitController()),
    ),
    GetPage(
      name: Routes.photos,
      page: () => const PhotosView(),
      binding: BindingsBuilder.put(() => PhotosController()),
    ),
    GetPage(
      name: Routes.location,
      page: () => const LocationView(),
      binding: BindingsBuilder.put(() => LocationController()),
    ),
    GetPage(
      name: Routes.mapEditor,
      page: () => const MapEditorView(),
      binding: BindingsBuilder.put(() => MapEditorController()),
      fullscreenDialog: true,
    ),
    GetPage(name: Routes.notes, page: () => const NotesView(), binding: BindingsBuilder.put(() => NotesController())),
    GetPage(
      name: Routes.noteEditor,
      page: () => const NoteEditorView(),
      binding: BindingsBuilder.put(() => NoteEditorController()),
    ),
    GetPage(
      name: Routes.samples,
      page: () => const SamplesView(),
      binding: BindingsBuilder.put(() => SamplesController()),
    ),
    GetPage(
      name: Routes.sampleForm,
      page: () => const SampleFormView(),
      binding: BindingsBuilder.put(() => SampleFormController()),
    ),
    GetPage(
      name: Routes.sketch,
      page: () => const SketchView(),
      binding: BindingsBuilder.put(() => SketchController()),
      fullscreenDialog: true,
    ),
    GetPage(name: Routes.scanner, page: () => const ScannerView(), fullscreenDialog: true),
    GetPage(name: Routes.news, page: () => const NewsView(), binding: BindingsBuilder.put(() => NewsController())),
    GetPage(name: Routes.newsDetail, page: () => const NewsDetailView()),
    GetPage(name: Routes.leave, page: () => const LeaveView(), binding: BindingsBuilder.put(() => LeaveController())),
    GetPage(
      name: Routes.leaveApply,
      page: () => const LeaveApplyView(),
      binding: BindingsBuilder.put(() => LeaveApplyController()),
    ),
  ];
}
