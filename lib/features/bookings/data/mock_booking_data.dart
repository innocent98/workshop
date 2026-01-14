import 'package:workchop/features/bookings/domain/models/booking.dart';

class MockBookingData {
  static final List<Booking> clientBookings = [
    Booking(
      id: '1',
      artisanName: 'Paul Chibuikem',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Plumber',
      isVerified: true,
      status: 'ongoing',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      services: ['Leaking Faucet Repair', 'Pipe Unclogging'],
    ),
    Booking(
      id: '2',
      artisanName: 'Sanni Kazeem',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Electrician',
      isVerified: false,
      status: 'requested',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      services: ['AC Installation', 'Wiring Repair'],
    ),
    Booking(
      id: '3',
      artisanName: 'Fola Ade',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Carpenter',
      isVerified: true,
      status: 'completed',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      services: ['Furniture Assembly'],
    ),
  ];
}
