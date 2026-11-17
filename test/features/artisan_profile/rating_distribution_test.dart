import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/features/artisan_profile/domain/models/artisan_public_profile.dart';
import 'package:workchop/features/artisan_profile/presentation/widgets/rating_distribution.dart';

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
);

void main() {
  testWidgets('hidden when every bucket is zero', (tester) async {
    await tester.pumpWidget(
      _host(
        const RatingDistribution(distribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0}),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('0%'), findsNothing);
  });

  testWidgets('shows five bars when there is data', (tester) async {
    await tester.pumpWidget(
      _host(
        const RatingDistribution(
          distribution: {5: 60, 4: 40, 3: 0, 2: 0, 1: 0},
        ),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
    expect(find.text('60%'), findsOneWidget);
  });

  test('hourly rate uses thousand separators', () {
    const profile = ArtisanPublicProfile(
      id: '1',
      fullName: 'Test Artisan',
      hourlyRateMin: 5000,
      hourlyRateMax: 10000,
      averageRating: 3.7,
      totalRatings: 3,
      totalJobsCompleted: 2,
    );
    expect(profile.hourlyRateRange, '₦5,000 - ₦10,000/hr');
  });
}
