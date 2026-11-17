import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/constants/app_colors.dart';
import 'package:workchop/core/widgets/common/avatar_placeholder.dart';
import 'package:workchop/core/widgets/common/verified_badge.dart';
import 'package:workchop/features/booking/presentation/widgets/service_checkbox.dart';

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('avatarInitials', () {
    test('two names give both initials', () {
      expect(avatarInitials('Ada Obi'), 'AO');
    });
    test('uses first and last of several names', () {
      expect(avatarInitials('ada  chidi obi'), 'AO');
    });
    test('single name gives one initial', () {
      expect(avatarInitials('Ada'), 'A');
    });
    test('empty or null gives nothing', () {
      expect(avatarInitials(''), '');
      expect(avatarInitials('   '), '');
      expect(avatarInitials(null), '');
    });
  });

  testWidgets('AvatarPlaceholder shows initials, or a person icon', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const AvatarPlaceholder(name: 'Ada Obi')));
    expect(find.text('AO'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing);

    await tester.pumpWidget(_host(const AvatarPlaceholder()));
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('ProfileAvatar falls back to placeholder without a URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const ProfileAvatar(imageUrl: '', name: 'Ada Obi')),
    );
    expect(find.text('AO'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('VerifiedBadge is the success green verified icon', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const VerifiedBadge()));
    final icon = tester.widget<Icon>(find.byIcon(Icons.verified));
    expect(icon.color, AppColors.success);
  });

  testWidgets('ServiceCheckbox: unchecked is empty, checked shows a tick', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const ServiceCheckbox(selected: false)));
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.pumpWidget(_host(const ServiceCheckbox(selected: true)));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
