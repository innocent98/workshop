class Booking {
  final String id;
  final String artisanName;
  final String artisanAvatar;
  final String serviceType;
  final bool isVerified;
  final String status; // 'requested', 'ongoing', 'completed'
  final DateTime dateTime;
  final List<String> services;

  Booking({
    required this.id,
    required this.artisanName,
    required this.artisanAvatar,
    required this.serviceType,
    required this.isVerified,
    required this.status,
    required this.dateTime,
    required this.services,
  });
}
