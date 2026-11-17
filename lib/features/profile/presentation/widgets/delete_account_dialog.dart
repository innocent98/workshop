import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_error_mapper.dart';

/// Confirmation step for permanent account deletion.
///
/// The confirm button stays disabled until the user types [confirmationWord],
/// so the action is always deliberate. [onConfirm] performs the deletion; the
/// dialog shows a loading state while it runs, pops with `true` on success, and
/// on failure stays open (the user remains signed in) with the reason and a
/// "Try again" button.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.onConfirm});

  static const String confirmationWord = 'DELETE';

  final Future<void> Function() onConfirm;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isDeleting = false;
  String? _errorMessage;

  bool get _confirmed =>
      _controller.text.trim() == DeleteAccountDialog.confirmationWord;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isDeleting || !_confirmed) return;
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _errorMessage = userMessage(
            e,
            fallback: 'We could not delete your account. Please try again.',
          );
        });
      }
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
                : Text(hasError ? 'Try again' : 'Delete account'),
          ),
        ],
      ),
    );
  }
}
