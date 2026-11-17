/// The single source of truth for how users reach Workchop support.
/// Change the number here and every call/WhatsApp entry point follows.
class SupportContact {
  const SupportContact._();

  /// E.164 number used for `tel:` links.
  static const String phone = '+2347042685209';

  /// Same number formatted for display.
  static const String phoneDisplay = '0704 268 5209';

  /// Digits only (no `+`), as `wa.me/<number>` expects.
  static const String whatsappNumber = '2347042685209';
}
