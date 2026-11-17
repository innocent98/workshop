/// Values needed to initialise the Dojah widget, from
/// `GET /profiles/artisans/me/verification/config`.
///
/// These are credentials: never log or persist them.
class DojahWidgetConfig {
  final bool configured;
  final String? appId;
  final String? publicKey;
  final String? widgetId;
  final String? environment;

  const DojahWidgetConfig({
    required this.configured,
    this.appId,
    this.publicKey,
    this.widgetId,
    this.environment,
  });

  /// The server says it is configured *and* every id the widget needs is
  /// present. Anything less must not burn an attempt on `start`.
  bool get isUsable =>
      configured &&
      (appId?.isNotEmpty ?? false) &&
      (publicKey?.isNotEmpty ?? false) &&
      (widgetId?.isNotEmpty ?? false);
}
