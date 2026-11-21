/// Reasons accepted by `POST /reviews/{id}/report` (contract: abusive, spam,
/// fake, other). `details` is optional free text, max 500 characters.
enum ReviewReportReason {
  abusive('abusive', 'Abusive or offensive'),
  spam('spam', 'Spam'),
  fake('fake', 'Fake or not a real customer'),
  other('other', 'Something else');

  const ReviewReportReason(this.apiValue, this.label);

  final String apiValue;
  final String label;
}
