import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/widgets/text/text_widgets.dart';

class LocationGatePage extends ConsumerStatefulWidget {
  final String scope;
  final String nextRoute;

  const LocationGatePage({
    super.key,
    required this.scope,
    required this.nextRoute,
  });

  @override
  ConsumerState<LocationGatePage> createState() => _LocationGatePageState();
}

class _LocationGatePageState extends ConsumerState<LocationGatePage> {
  bool _isChecking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAndProceed();
    });
  }

  Future<void> _requestAndProceed() async {
    if (_isChecking) {
      return;
    }
    setState(() {
      _isChecking = true;
      _error = null;
    });

    final notifier = ref.read(locationProvider.notifier);
    final roleLabel = widget.scope == 'artisan' ? 'artisan' : 'client';

    final granted = await notifier.requestPermission(scope: widget.scope);
    if (!granted) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isChecking = false;
        _error = 'Location permission is required for $roleLabel accounts.';
      });
      return;
    }

    await notifier.refreshLocation();
    final location = ref.read(locationProvider).asData?.value;
    final hasRealFix =
        location != null &&
        location.permissionGranted &&
        !location.isUsingFallback;

    if (!mounted) {
      return;
    }

    if (!hasRealFix) {
      setState(() {
        _isChecking = false;
        _error =
            'Unable to get your current location. Please enable GPS and retry.';
      });
      return;
    }

    context.go(widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 72.r),
                SizedBox(height: 16.h),
                BodyText(
                  'Enable Location',
                  size: BodySize.large,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 8.h),
                BodyText(
                  'Location access is required to continue.',
                  size: BodySize.medium,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                if (_error != null) ...[
                  SizedBox(height: 12.h),
                  BodyText(
                    _error!,
                    size: BodySize.small,
                    color: Colors.red,
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _requestAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: _isChecking
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Grant Location Access'),
                  ),
                ),
                SizedBox(height: 10.h),
                TextButton(
                  onPressed: () =>
                      ref.read(locationProvider.notifier).openAppSettings(),
                  child: const Text('Open App Settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
