# CU Farmer

Offline-first field audit app for organic certification auditors.
Flutter + Dart + GetX.

## Run

```bash
flutter pub get
flutter run
```

The app runs on mock data out of the box (`AppConfig.useMockData = true`).

## Structure

```
lib/
  main.dart                     # DI setup + GetMaterialApp
  app/
    core/
      config/app_config.dart    # API base URL, mock switch, version
      theme/                    # colors, Material 3 theme (light + dark), status colors
      utils/formatters.dart     # dates, numbers, initials
      widgets/                  # shared UI: AppCard, StatusPill, ProgressRing, PhotoPicker…
    data/
      models/                   # plain Dart models (Farmer, AuditNote, FieldSample…)
      providers/api_client.dart # GetConnect client with auth header
      repositories/
        audit_repository.dart       # interface the UI depends on
        mock_audit_repository.dart  # in-memory implementation
        mock_data.dart              # sample data
    services/                   # AuthService, SyncService, ThemeService (permanent)
    routes/                     # route names + GetPage bindings
    modules/                    # one folder per feature: *_controller.dart + *_view.dart
```

## Feature map

| Module | What it does |
| --- | --- |
| auth | Splash, Microsoft sign-in |
| shell | Bottom navigation: Home · Audits · Schedule · Profile |
| home | Greeting, sync status, stats, next audit, active projects, news |
| audits | Projects list, download for offline use, upload changes |
| units | Project → production units (F01…) / processing units |
| farmers | Farmer list with search, filters, star |
| farmer | Farmer workspace, details, changes since last audit |
| processing | Processing unit workspace |
| photos / location / notes / samples | Shared by farmers and processing units via `SubjectRef` |
| sketch | Sampling map drawing pad (pen, line, box, circle, eraser, undo/redo) |
| scanner | QR/barcode seal scanner with manual entry |
| schedule | Date strip, accept/decline audit invitations |
| leave / news / profile | Leave balance & requests, work location, announcements, settings |

## Connecting the backend

1. Create `ApiAuditRepository implements AuditRepository` in `data/repositories/`
   using `Get.find<ApiClient>()` (`getJson` / `postJson`), and add `fromJson` / `toJson`
   to the models you need.
2. In `main.dart`, register it instead of the mock:
   `Get.put<AuditRepository>(ApiAuditRepository(), permanent: true);`
3. Set `AppConfig.useMockData = false` and pass the host:
   `flutter run --dart-define=API_BASE_URL=https://your-api.com`
4. Replace the mock in `AuthService.signInWithMicrosoft()` with Azure AD / MSAL.

Controllers and views don't change; they only talk to `AuditRepository`.

## Asset credits

The login photo is CC BY 4.0 and needs attribution. See [assets/CREDITS.md](assets/CREDITS.md).
