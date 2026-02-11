import '../domain/models/support_category.dart';
import '../domain/models/support_ticket.dart';
import '../domain/models/quick_help.dart';
import '../domain/models/faq.dart';

class MockSupportData {
  // Support Categories
  static const List<SupportCategory> supportCategories = [
    SupportCategory(
      id: '1',
      title: 'Booking\nProblems',
      iconPath: 'assets/images/support_icons/booking.png',
    ),
    SupportCategory(
      id: '2',
      title: 'Artisan\nIssues',
      iconPath: 'assets/images/support_icons/artisan.png',
    ),
    SupportCategory(
      id: '3',
      title: 'Payment\nProblems',
      iconPath: 'assets/images/support_icons/payment_problems.png',
    ),
    SupportCategory(
      id: '4',
      title: 'Safety\nConcerns',
      iconPath: 'assets/images/support_icons/safety.png',
    ),
    SupportCategory(
      id: '5',
      title: 'Account\nHelp',
      iconPath: 'assets/images/support_icons/account_help.png',
    ),
    SupportCategory(
      id: '6',
      title: 'Notification\nHelp',
      iconPath: 'assets/images/support_icons/notification_help.png',
    ),
  ];

  // Quick Help Cards
  static const List<QuickHelp> quickHelpCards = [
    QuickHelp(
      id: '1',
      title: 'How payments work on Workchop',
      ctaText: 'Find out',
      backgroundColor: '#E8E8E8',
    ),
    QuickHelp(
      id: '2',
      title: 'When can I chat with an artisan?',
      ctaText: 'Find out',
      backgroundColor: '#FFF9E6',
    ),
    QuickHelp(
      id: '3',
      title: 'How to cancel a booking',
      ctaText: 'Find out',
      backgroundColor: '#E8F5E9',
    ),
  ];

  // Support Tickets
  static final List<SupportTicket> supportTickets = [
    SupportTicket(
      id: '1',
      title: 'Artisan accepted but is not responding',
      submittedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      status: TicketStatus.open,
    ),
    SupportTicket(
      id: '2',
      title: 'Artisan accepted but is not responding',
      submittedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      status: TicketStatus.open,
    ),
    SupportTicket(
      id: '3',
      title: 'Payment not processed correctly',
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: TicketStatus.inReview,
    ),
    SupportTicket(
      id: '4',
      title: 'Wrong service category displayed',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: TicketStatus.resolved,
    ),
  ];

  // FAQs
  static const List<FAQ> faqs = [
    FAQ(
      id: '1',
      question: 'Why is my booking still pending?',
      answer:
          'Pending means the artisan has not accepted or rejected yet. Once accepted, the next step is payment from the client.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: '2',
      question: 'Can I cancel a booking?',
      answer:
          'Yes. Cancellation requires a reason. Paid or progressed bookings may be restricted and should be handled through support.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: '3',
      question: 'Can I update a booking request?',
      answer:
          'Only pending booking requests can be updated. Accepted requests should be cancelled and rebooked.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: '4',
      question: 'When does the client pay?',
      answer:
          'Client payment is made after the artisan accepts the booking. The booking then moves to Paid and the artisan can start work.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: '5',
      question: 'When can an artisan request payout?',
      answer:
          'Payout is allowed for successful payments tied to completed bookings that are client-confirmed or past the dispute window.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: '10',
      question: 'Why is Available for Payout lower than total earnings?',
      answer:
          'Total Earnings includes both withdrawn and pending amounts. Available for Payout only includes eligible funds that can be withdrawn now.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: '6',
      question: 'How do I complete a booking flow correctly?',
      answer:
          'Flow is: client books, artisan accepts, client pays, artisan starts, artisan completes, client confirms completion.',
      category: FAQCategory.appGuide,
    ),
    FAQ(
      id: '7',
      question: 'Why am I not getting notifications?',
      answer:
          'Enable system notifications for Workchop on your device and make sure app permissions are granted.',
      category: FAQCategory.appGuide,
    ),
    FAQ(
      id: '8',
      question: 'What if a job is completed but disputed?',
      answer:
          'Disputed completions are blocked from payout release until the dispute is resolved.',
      category: FAQCategory.safety,
    ),
    FAQ(
      id: '9',
      question: 'How is artisan verification handled currently?',
      answer:
          'At present, artisan verification is tied to current backend rules and may evolve as advanced verification is introduced.',
      category: FAQCategory.safety,
    ),
  ];

  // Helper methods to filter data
  static List<SupportTicket> getTicketsByStatus(TicketStatus status) {
    return supportTickets.where((ticket) => ticket.status == status).toList();
  }

  static List<FAQ> getFAQsByCategory(FAQCategory category) {
    return faqs.where((faq) => faq.category == category).toList();
  }
}
