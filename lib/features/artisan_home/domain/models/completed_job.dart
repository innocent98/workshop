class CompletedJob {
  final String id;
  final String clientName;
  final String clientAvatar;
  final String service;
  final DateTime completedDate;
  final String? workImageUrl;
  final bool addedToPortfolio;

  const CompletedJob({
    required this.id,
    required this.clientName,
    required this.clientAvatar,
    required this.service,
    required this.completedDate,
    this.workImageUrl,
    this.addedToPortfolio = false,
  });
}
