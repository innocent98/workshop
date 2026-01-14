enum JobType {
  instant,
  scheduled,
}

enum JobStatus {
  pending,
  ongoing,
  completed,
  cancelled,
}

class JobRequest {
  final String id;
  final String clientName;
  final String clientAvatar;
  final String service;
  final String description;
  final DateTime date;
  final JobType type;
  final String location;
  final double distance; // in km
  final JobStatus status;

  const JobRequest({
    required this.id,
    required this.clientName,
    required this.clientAvatar,
    required this.service,
    required this.description,
    required this.date,
    required this.type,
    required this.location,
    required this.distance,
    this.status = JobStatus.pending,
  });

  String get formattedDate {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
