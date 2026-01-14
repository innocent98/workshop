enum TicketStatus {
  open,
  inReview,
  resolved,
}

class SupportTicket {
  final String id;
  final String title;
  final DateTime submittedAt;
  final TicketStatus status;

  const SupportTicket({
    required this.id,
    required this.title,
    required this.submittedAt,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inReview:
        return 'In Review';
      case TicketStatus.resolved:
        return 'Resolved';
    }
  }
}
