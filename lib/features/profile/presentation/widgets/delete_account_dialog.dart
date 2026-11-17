import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';

/// Performs the deletion with the re-authentication the backend demands: the
/// account [password], or a fresh Firebase [googleToken] for Google-only
/// accounts.
typedef DeleteAccountSubmit =
    Future<void> Function({String? password, String? googleToken});

/// Confirmation step for permanent account deletion.
///
/// The confirm button stays disabled until the user types [confirmationWord],
/// so the action is always deliberate. The user also re-enters their password
/// (the backend refuses deletion without it). Accounts with no password (Google
/// sign-in only) leave it blank; the backend then answers `reauth_required` and
/// the dialog switches to a "Confirm with Google" step that calls
/// [onRequestGoogleToken]. [onConfirm] performs the deletion; the
/// dialog shows a loading state while it runs, pops with `true` on success, and
/// on failure stays open (the user remains signed in) with the reason and a
/// "Try again" button.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
    this.onRequestGoogleToken,
  });

  static const String confirmationWord = 'DELETE';

  /// Backend error code for a Google-only account that must re-authenticate.
  static const String googleReauthCode = 'reauth_required';

  final DeleteAccountSubmit onConfirm;

  /// Returns a fresh Firebase ID token, or null if the user backed out.
  final Future<String?> Function()? onRequestGoogleToken;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;
  bool _googleReauth = false;
  String? _errorMessage;

  bool get _confirmed =>
      _controller.text.trim() == DeleteAccountDialog.confirmationWord;

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isDeleting || !_confirmed) return;
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });
    try {
      String? googleToken;
      if (_googleReauth) {
        googleToken = await widget.onRequestGoogleToken?.call();
        if (googleToken == null) {
          // The user dismissed the Google sheet: nothing happened.
          if (mounted) setState(() => _isDeleting = false);
          return;
        }
      }
      await widget.onConfirm(
        password: _googleReauth ? null : _passwordController.text,
        googleToken: googleToken,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      if (!_googleReauth &&
          widget.onRequestGoogleToken != null &&
          e is ApiException &&
          e.code == DeleteAccountDialog.googleReauthCode) {
        setState(() {
          _isDeleting = false;
          _googleReauth = true;
          _errorMessage = null;
        });
        return;
      }
      setState(() {
        _isDeleting = false;
        _errorMessage = userMessage(
          e,
          fallback: 'We could not delete your account. Please try again.',
        );
      });
    }
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h, right: 8.w),
            child: Container(
              width: 5.r,
              height: 5.r,
              decoration: const BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;

    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('Delete your account?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'This is permanent and cannot be undone. You will lose:',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
              _bullet('Your profile, photos and saved details'),
              _bullet('Your booking and job history'),
              _bullet(
                'Access to any earnings, wallet balance or pending payments',
              ),
              SizedBox(height: 16.h),
              if (_googleReauth)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    'This account uses Google sign-in. You will be asked to '
                    'confirm with Google before it is deleted.',
                    key: const Key('delete_account_google_note'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                )
              else ...[
                TextField(
                  key: const Key('delete_account_password_field'),
                  controller: _passwordController,
                  enabled: !_isDeleting,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.password],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Your password',
                    helperText: 'Google account? Leave blank.',
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              TextField(
                key: const Key('delete_account_confirm_field'),
                controller: _controller,
                enabled: !_isDeleting,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText:
                      'Type ${DeleteAccountDialog.confirmationWord} to confirm',
                ),
              ),
              if (hasError) ...[
                SizedBox(height: 12.h),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _errorMessage!,
                    key: const Key('delete_account_error'),
                    style: TextStyle(fontSize: 13.sp, color: AppColors.error),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your account has not been deleted and you are still signed in.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('delete_account_cancel'),
            onPressed: _isDeleting
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('delete_account_confirm'),
            onPressed: (_confirmed && !_isDeleting) ? _submit : null,
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: _isDeleting
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _googleReauth
                        ? 'Confirm with Google'
                        : (hasError ? 'Try again' : 'Delete account'),
                  ),
          ),
        ],
      ),
    );
  }
}
