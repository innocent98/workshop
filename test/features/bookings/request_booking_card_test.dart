import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/bookings/domain/models/booking.dart';
import 'package:workchop/features/bookings/presentation/widgets/request_booking_card.dart';

Widget _host(Booking booking) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: RequestBookingCard(booking: booking)),
    ),
  ),
);

Booking _booking({double? min, double? max}) => Booking(
  id: '1',
  artisanName: 'Ada Obi',
  artisanAvatar: '',
  serviceType: 'Plumbing',
  isVerified: false,
  status: 'requested',
  dateTime: DateTime(2030, 5, 1, 10),
  services: const ['Fix the kitchen sink'],
  budgetMin: min,
  budgetMax: max,
);

void main() {
  testWidgets('shows the budget range with thousand separators', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_booking(min: 5000, max: 8000)));
    expect(find.text('₦5,000 - ₦8,000'), findsOneWidget);
  });

  testWidgets('hides the budget row when no budget was set', (tester) async {
    await tester.pumpWidget(_host(_booking(min: 0, max: 0)));
    expect(find.byKey(const Key('request_card_budget')), findsNothing);

    await tester.pumpWidget(_host(_booking()));
    expect(find.byKey(const Key('request_card_budget')), findsNothing);
  });

  testWidgets('shows initials, not a stock photo, without an avatar', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_booking(min: 5000, max: 8000)));
    expect(find.text('AO'), findsOneWidget);
  });
}
