import '../../domain/models/dojah_widget_config.dart';

/// Wire model for `GET .../verification/config`. Lenient: a missing field
/// means "not configured", never a crash.
class DojahConfigResponse {
  final bool configured;
  final String? appId;
  final String? publicKey;
  final String? widgetId;
  final String? environment;

  const DojahConfigResponse({
    this.configured = false,
    this.appId,
    this.publicKey,
    this.widgetId,
    this.environment,
  });

  factory DojahConfigResponse.fromJson(Map<String, dynamic> json) {
    return DojahConfigResponse(
      configured: json['configured'] == true,
      appId: _string(json['app_id']),
      publicKey: _string(json['public_key']),
      widgetId: _string(json['widget_id']),
      environment: _string(json['environment']),
    );
  }

  DojahWidgetConfig toDomain() => DojahWidgetConfig(
    configured: configured,
    appId: appId,
    publicKey: publicKey,
    widgetId: widgetId,
    environment: environment,
  );

  static String? _string(Object? v) => v is String && v.isNotEmpty ? v : null;
}
