import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/dispute_rules.dart';

/// Asks the client why they dispute a completed job. Pops with the trimmed
/// reason (10-500 characters, same as the backend), or null when cancelled.
class DisputeCompletionDialog extends StatefulWidget {
  const DisputeCompletionDialog({super.key});

  @override
  State<DisputeCompletionDialog> createState() =>
      _DisputeCompletionDialogState();
}

class _DisputeCompletionDialogState extends State<DisputeCompletionDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = validateDisputeReason(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dispute completion'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us what is wrong with the work. This marks the job as '
              'disputed instead of confirming it, and cannot be undone here.',
              style: TextStyle(fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            TextField(
              key: const Key('dispute_reason_field'),
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              maxLength: kDisputeReasonMaxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'e.g. The leak is still there after the repair',
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep as is'),
        ),
        FilledButton(
          key: const Key('dispute_submit'),
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
          onPressed: _submit,
          child: const Text('Submit dispute'),
        ),
      ],
    );
  }
}
