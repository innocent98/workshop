import '../domain/models/booking.dart';

class MockBookingsData {
  static final List<Booking> requestBookings = [
    Booking(
      id: '1',
      artisanName: 'Saviour Theophilus',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Carpenter',
      isVerified: true,
      status: 'requested',
      dateTime: DateTime(2025, 11, 27, 7, 25),
      services: [
        'Door and Window Casing Installation',
        'Hardware Installation (Hinges, Drawer Slides, Locks)',
        'Advanced Wood Joinery',
      ],
    ),
    Booking(
      id: '2',
      artisanName: 'Glory-Praise Ruth',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Markup Artist',
      isVerified: true,
      status: 'requested',
      dateTime: DateTime(2025, 11, 27, 7, 25),
      services: [
        'Door and Window Casing Installation',
        'Hardware Installation (Hinges, Drawer Slides, Locks)',
        'Advanced Wood Joinery',
      ],
    ),
  ];

  static final List<Booking> ongoingBookings = [
    Booking(
      id: '3',
      artisanName: 'Idem Etop',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Mechanic',
      isVerified: true,
      status: 'ongoing',
      dateTime: DateTime(2025, 11, 27, 7, 25),
      services: [
        'Door and Window Casing Installation',
        'Hardware Installation (Hinges, Drawer Slides, Locks)',
        'Advanced Wood Joinery',
      ],
    ),
    Booking(
      id: '4',
      artisanName: 'Paul Attah',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Fashion Designer',
      isVerified: true,
      status: 'ongoing',
      dateTime: DateTime(2025, 11, 27, 7, 25),
      services: [
        'Door and Window Casing Installation',
        'Hardware Installation (Hinges, Drawer Slides, Locks)',
        'Advanced Wood Joinery',
      ],
    ),
  ];

  static final List<Booking> completedBookings = [
    Booking(
      id: '5',
      artisanName: 'Mercy Bassey',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Carpenter',
      isVerified: true,
      status: 'completed',
      dateTime: DateTime(2025, 11, 27, 7, 25),
      services: [
        'Door and Window Casing Installation',
        'Hardware Installation (Hinges, Drawer Slides, Locks)',
        'Advanced Wood Joinery',
      ],
    ),
    Booking(
      id: '6',
      artisanName: 'Jeremiah Udoh',
      artisanAvatar: 'assets/images/regular.jpg',
      serviceType: 'Carpenter',
      isVerified: true,
      status: 'completed',
      dateTime: DateTime(2025, 11, 27, 7, 25),
      services: [
        'Door and Window Casing Installation',
        'Hardware Installation (Hinges, Drawer Slides, Locks)',
        'Advanced Wood Joinery',
      ],
    ),
  ];
}
