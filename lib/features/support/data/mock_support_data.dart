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
      question: 'Artisan accepted but is not responding',
      answer: 'If an artisan accepts your booking but doesn\'t respond, please wait 24 hours before contacting support.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: '2',
      question: 'Why can\'t I chat yet?',
      answer: 'Chat becomes available once an artisan accepts your booking request.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: '3',
      question: 'How long before I can cancel?',
      answer: 'You can cancel a booking up to 2 hours before the scheduled time without penalty.',
      category: FAQCategory.bookings,
    ),
    FAQ(
      id: '4',
      question: 'When will I be charged?',
      answer: 'Payment is processed after the service is completed and confirmed.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: '5',
      question: 'What payment methods are accepted?',
      answer: 'We accept credit cards, debit cards, and mobile money transfers.',
      category: FAQCategory.payments,
    ),
    FAQ(
      id: '6',
      question: 'How do I update my profile?',
      answer: 'Go to Profile tab and tap the Edit button to update your information.',
      category: FAQCategory.appGuide,
    ),
    FAQ(
      id: '7',
      question: 'How do I enable notifications?',
      answer: 'Go to your phone Settings > Workchop > Notifications and enable them.',
      category: FAQCategory.appGuide,
    ),
    FAQ(
      id: '8',
      question: 'Is my payment information secure?',
      answer: 'Yes, all payment information is encrypted and securely stored.',
      category: FAQCategory.safety,
    ),
    FAQ(
      id: '9',
      question: 'How are artisans verified?',
      answer: 'All artisans go through a verification process including ID check and skills assessment.',
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
