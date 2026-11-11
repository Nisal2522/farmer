/// App-wide configuration.
///
/// Switch [useMockData] to `false` once the real backend repository is wired
/// up, and pass the API host at build time:
/// `flutter run --dart-define=API_BASE_URL=https://your-api.com`
class AppConfig {
  AppConfig._();

  static const appName = 'CU Farmer';
  static const version = '3.0.0';

  static const useMockData = true;

  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');

  static const requestTimeout = Duration(seconds: 30);
}
