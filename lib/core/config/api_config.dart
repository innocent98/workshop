/// Deployment environments the app can run in. Selected at build/run time with
/// `--dart-define=APP_ENV=<dev|staging|prod>`.
enum AppEnv {
  dev,
  staging,
  prod;

  static AppEnv parse(String value) => AppEnv.values.firstWhere(
    (e) => e.name == value.toLowerCase(),
    orElse: () => AppEnv.prod,
  );
}

/// Build-time configuration. Nothing here is a secret: values are baked into
/// the binary, so never put keys or tokens in a `--dart-define`.
///
/// ```
/// flutter run --dart-define=APP_ENV=dev \
///             --dart-define=API_BASE_URL=http://localhost:8000/api/v1
/// ```
class ApiConfig {
  const ApiConfig._();

  /// Base URL of the Workchop API, including the `/api/v1` prefix and no
  /// trailing slash. The default is a production placeholder; real builds must
  /// pass `--dart-define=API_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.workchop.example/api/v1',
  );

  static const String _appEnvRaw = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static final AppEnv env = AppEnv.parse(_appEnvRaw);

  static bool get isProd => env == AppEnv.prod;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
