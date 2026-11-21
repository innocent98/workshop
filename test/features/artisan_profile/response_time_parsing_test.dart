import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/widgets/common/response_time_label.dart';
import 'package:workchop/features/artisan_profile/data/models/artisan_public_profile_response_model.dart';
import 'package:workchop/features/client_home/domain/models/artisan.dart';
import 'package:workchop/features/search/data/models/artisan_search_model.dart';

// Shapes copied from the captured responses (08, 09, 10 in
// docs/fe-captures/reviews-response-time of the backend repo).
Map<String, dynamic> _profileJson({
  Object? responseTime = 33,
  bool omit = false,
}) => {
  'id': 'df631428-50f0-42d4-a868-59aaffb7a300',
  'full_name': 'Demo Artisan',
  'profile_picture_url': null,
  'bio': null,
  'location_address': '12 Example Street, Lagos',
  'service_radius_km': 10.0,
  'hourly_rate_min': null,
  'hourly_rate_max': null,
  'years_of_experience': null,
  'specialization': 'Plumbing',
  'is_verified': false,
  'availability_status': 'available',
  'average_rating': 0.0,
  'total_ratings': 0,
  'total_jobs_completed': 0,
  if (!omit) 'response_time_avg_minutes': responseTime,
};

Map<String, dynamic> _searchJson({
  Object? responseTime = 33,
  bool omit = false,
}) => {
  'id': 'df631428-50f0-42d4-a868-59aaffb7a300',
  'full_name': 'Demo Artisan',
  'profile_picture': null,
  'location_address': '12 Example Street, Lagos',
  'specialization': 'Plumbing',
  'is_verified': false,
  'average_rating': 4.5,
  'total_ratings': 2,
  'total_jobs_completed': 3,
  if (!omit) 'response_time_avg_minutes': responseTime,
  'acceptance_rate': 0.0,
  'distance_km': 0.0,
  'services': [],
  'category_name': null,
  'portfolio_sample': null,
};

void main() {
  group('public profile parsing', () {
    test('reads the integer', () {
      final m = ArtisanPublicProfileResponseModel.fromJson(_profileJson());
      expect(m.responseTimeAvgMinutes, 33);
      expect(m.toDomain().responseTimeAvgMinutes, 33);
    });

    test('explicit null (newcomer) stays null', () {
      final m = ArtisanPublicProfileResponseModel.fromJson(
        _profileJson(responseTime: null),
      );
      expect(m.toDomain().responseTimeAvgMinutes, isNull);
    });

    test('absent field stays null', () {
      final m = ArtisanPublicProfileResponseModel.fromJson(
        _profileJson(omit: true),
      );
      expect(m.toDomain().responseTimeAvgMinutes, isNull);
    });
  });

  group('search result parsing', () {
    test('reads the integer inside the result item', () {
      final m = ArtisanSearchModel.fromJson(_searchJson());
      expect(m.responseTimeAvgMinutes, 33);
      expect(Artisan.fromSearchModel(m).responseTimeAvgMinutes, 33);
    });

    test('null and absent both parse to null', () {
      expect(
        ArtisanSearchModel.fromJson(
          _searchJson(responseTime: null),
        ).responseTimeAvgMinutes,
        isNull,
      );
      expect(
        ArtisanSearchModel.fromJson(
          _searchJson(omit: true),
        ).responseTimeAvgMinutes,
        isNull,
      );
    });

    test('survives withPreferredServiceFromQuery', () {
      final artisan = Artisan.fromSearchModel(
        ArtisanSearchModel.fromJson({
          ..._searchJson(),
          'services': [
            {'id': '7', 'name': 'Pipe repair'},
          ],
        }),
      );
      final copy = artisan.withPreferredServiceFromQuery('pipe repair');
      expect(copy.preferredService, isNotNull);
      expect(copy.responseTimeAvgMinutes, 33);
    });
  });

  group('ResponseTimeLabel', () {
    Future<void> pump(WidgetTester tester, int? minutes) => tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: Scaffold(body: ResponseTimeLabel(minutes: minutes)),
        ),
      ),
    );

    testWidgets('shows "Replies in ~12 min"', (tester) async {
      await pump(tester, 12);
      expect(find.text('Replies in ~12 min'), findsOneWidget);
    });

    testWidgets('renders nothing for null: no "0", no "N/A"', (tester) async {
      await pump(tester, null);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });
  });
}
