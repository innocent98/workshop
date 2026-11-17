/// A booking as returned by `GET /bookings` / `PATCH /bookings/{id}/...`.
/// Placeholder data only.
Map<String, dynamic> bookingJson({
  int id = 42,
  String status = 'completed',
  String? disputedAt,
  String? disputeReason,
  String? confirmedAt,
  String? deadlineAt = '2099-01-01T00:00:00Z',
}) {
  return {
    'id': id,
    'booking_reference': 'BK-TEST-$id',
    'customer_id': '00000000-0000-0000-0000-000000000001',
    'artisan_id': '00000000-0000-0000-0000-000000000002',
    'service_id': 7,
    'customer_name': 'Test Client',
    'artisan_name': 'Test Artisan',
    'artisan_phone_number': '+2348000000000',
    'service_name': 'Plumbing',
    'job_description': 'Fix the kitchen sink',
    'job_date': '2030-05-01T10:00:00Z',
    'job_address': '1 Test Street, Lagos',
    'job_latitude': '6.5244',
    'job_longitude': 3.3792,
    'budget_min': '5000.00',
    'budget_max': '8000.00',
    'agreed_amount': '6500.00',
    'negotiation_status': 'none',
    'status': status,
    'completion_confirmed_by_client_at': confirmedAt,
    'completion_confirmation_deadline_at': deadlineAt,
    'completion_disputed_at': disputedAt,
    'completion_dispute_reason': disputeReason,
    'progress_logs': [
      {
        'id': 1,
        'booking_id': id,
        'artisan_id': '00000000-0000-0000-0000-000000000002',
        'description': ' Started work ',
        'image_url': null,
        'created_at': '2030-05-01T11:00:00Z',
      },
    ],
    'created_at': '2030-04-30T09:00:00Z',
    'updated_at': '2030-05-01T12:00:00Z',
  };
}
