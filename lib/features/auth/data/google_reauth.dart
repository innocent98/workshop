import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_exception.dart';

/// Signs the user in with Google again and returns a fresh Firebase ID token,
/// which the backend requires to delete a Google-only account (it rejects tokens
/// older than a few minutes). Returns null when the user dismisses the Google
/// sheet.
Future<String?> requestFreshGoogleIdToken() async {
  final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
  if (googleUser == null) return null;

  final googleAuth = await googleUser.authentication;
  final credential = fb_auth.GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
  );
  final firebaseCredential = await fb_auth.FirebaseAuth.instance
      .signInWithCredential(credential);
  final token = await firebaseCredential.user?.getIdToken(true);
  if (token == null || token.isEmpty) {
    throw ApiException('Unable to get Google token. Please try again.');
  }
  return token;
}
