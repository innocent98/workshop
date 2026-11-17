/// Pure validation for a Nigerian National Identification Number (NIN).
///
/// The backend only accepts exactly 11 digits (`invalid_nin` otherwise), so
/// this mirrors that rule on the device before any request is made.
class NinValidator {
  NinValidator._();

  static const int length = 11;

  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  /// Returns an error message, or null when [value] is a valid NIN.
  static String? validate(String? value) {
    final nin = value?.trim() ?? '';
    if (nin.isEmpty) return 'Enter your 11-digit NIN';
    if (!_digitsOnly.hasMatch(nin)) return 'Your NIN can only contain digits';
    if (nin.length != length) return 'Your NIN must be exactly 11 digits';
    return null;
  }

  static bool isValid(String? value) => validate(value) == null;
}
