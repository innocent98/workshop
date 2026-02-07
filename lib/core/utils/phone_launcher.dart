import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchPhoneDialer(String phoneNumber) async {
  final cleaned = phoneNumber.trim();
  if (cleaned.isEmpty) {
    return false;
  }

  final uri = Uri(scheme: 'tel', path: cleaned);
  try {
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to launch dialer: $e');
    }
  }

  return false;
}
