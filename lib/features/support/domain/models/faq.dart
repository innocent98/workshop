enum FAQCategory {
  bookings,
  payments,
  appGuide,
  safety,
}

class FAQ {
  final String id;
  final String question;
  final String answer;
  final FAQCategory category;

  const FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  String get categoryLabel {
    switch (category) {
      case FAQCategory.bookings:
        return 'Bookings';
      case FAQCategory.payments:
        return 'Payments';
      case FAQCategory.appGuide:
        return 'App Guide';
      case FAQCategory.safety:
        return 'Safety';
    }
  }
}
