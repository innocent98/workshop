import '../domain/models/artisan_stats.dart';
import '../domain/models/job_request.dart';
import '../domain/models/completed_job.dart';

class MockArtisanData {
  // Artisan Statistics
  static const ArtisanStats stats = ArtisanStats(
    totalEarnings: 2800.0,
    completedJobs: 58,
  );

  // Incoming Job Requests
  static final List<JobRequest> jobRequests = [
    JobRequest(
      id: '1',
      clientName: 'Rambling Nancy',
      clientAvatar: 'assets/images/regular.jpg',
      service: 'Plumbing',
      description: 'Need urgent plumbing repair for leaking pipe in kitchen',
      date: DateTime.now().add(const Duration(days: 2)),
      type: JobType.instant,
      location: 'Ogudu, Lagos',
      distance: 3.6,
      status: JobStatus.ongoing,
    ),
    JobRequest(
      id: '2',
      clientName: 'John Doe',
      clientAvatar: 'assets/images/regular.jpg',
      service: 'Electrical',
      description: 'Installation of new electrical fittings in living room',
      date: DateTime.now().add(const Duration(days: 5)),
      type: JobType.scheduled,
      location: 'Yaba, Lagos',
      distance: 5.2,
      status: JobStatus.pending,
    ),
  ];

  // Recently Completed Jobs
  static final List<CompletedJob> completedJobs = [
    CompletedJob(
      id: '1',
      clientName: 'Sarah Williams',
      clientAvatar: 'assets/images/regular.jpg',
      service: 'Carpentry work completed',
      completedDate: DateTime.now().subtract(const Duration(hours: 2)),
      workImageUrl: 'assets/images/regular.jpg',
      addedToPortfolio: false,
    ),
    CompletedJob(
      id: '2',
      clientName: 'Mike Johnson',
      clientAvatar: 'assets/images/regular.jpg',
      service: 'Plumbing repair completed',
      completedDate: DateTime.now().subtract(const Duration(days: 1)),
      workImageUrl: 'assets/images/regular.jpg',
      addedToPortfolio: true,
    ),
  ];
}
