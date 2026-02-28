import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/text/header_text.dart';
import '../../../../core/widgets/text/body_text.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../core/models/user.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final OnboardingService _onboardingService = OnboardingService();
  final TokenStorageService _tokenStorage = TokenStorageService();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    if (_hasNavigated) return;

    final hasToken = await _tokenStorage.hasToken();
    final hasCompletedOnboarding = await _onboardingService
        .hasCompletedOnboarding();

    if (!mounted) return;

    if (hasToken) {
      try {
        // Wait for persisted auth state to fully hydrate before routing.
        final user = await ref.read(authProvider.future);
        if (!mounted) return;
        if (_hasNavigated) return;

        if (user != null) {
          await _goToRoleHomeWithLocationGate(user);
        } else {
          _hasNavigated = true;
          context.go(AppRoutes.login);
        }
      } catch (_) {
        if (mounted) {
          _hasNavigated = true;
          context.go(AppRoutes.login);
        }
      }
    } else if (hasCompletedOnboarding) {
      if (mounted) {
        _hasNavigated = true;
        context.go(AppRoutes.login);
      }
    } else {
      if (mounted) {
        _hasNavigated = true;
        context.go(AppRoutes.userTypeSelection);
      }
    }
  }

  Future<void> _goToRoleHomeWithLocationGate(User user) async {
    final route = user.role == UserRole.artisan
        ? AppRoutes.artisanHome
        : AppRoutes.clientHome;
    final scope = user.role == UserRole.artisan ? 'artisan' : 'client';

    final locationNotifier = ref.read(locationProvider.notifier);
    await locationNotifier.refreshLocation();
    final locationData = ref.read(locationProvider).asData?.value;
    final hasRealLocation =
        locationData != null &&
        locationData.permissionGranted &&
        !locationData.isUsingFallback;

    if (!mounted) return;

    if (hasRealLocation) {
      _hasNavigated = true;
      context.go(route);
      return;
    }

    _hasNavigated = true;
    context.go(
      AppRoutes.locationGate,
      extra: {'scope': scope, 'nextRoute': route},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wrench Icon
                Icon(Icons.build_rounded, size: 100, color: Colors.white),
                SizedBox(height: AppSizes.spacingLarge * 1.5),

                // App Name - Using HeaderText with Bricolage Grotesque
                HeaderText(
                  'Workchop',
                  size: HeaderSize.h1,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                SizedBox(height: AppSizes.spacing),

                // Tagline - Using BodyText with Poppins
                BodyText(
                  'Connecting Artisans & Clients',
                  size: BodySize.large,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
