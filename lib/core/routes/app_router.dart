import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/token_storage_service.dart';
import '../models/user.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/user_type_selection_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_carousel_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/personal_information_page.dart';
import '../../features/auth/presentation/pages/password_page.dart';
import '../../features/auth/presentation/pages/phone_verification_page.dart';
import '../../features/auth/presentation/pages/service_selection_page.dart';
import '../../features/auth/presentation/pages/profile_picture_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_email_page.dart';
import '../../features/auth/presentation/pages/forgot_password_otp_page.dart';
import '../../features/auth/presentation/pages/forgot_password_new_password_page.dart';
import '../../features/client_home/presentation/pages/service_categories_page.dart';
import '../../features/client_home/presentation/pages/all_artisans_page.dart';
import '../../features/main_navigation/presentation/pages/main_navigation_page.dart';
import '../../features/search_result/presentation/pages/search_result_page.dart';
import '../../features/artisan_profile/presentation/pages/artisan_profile_page.dart';
import '../../features/booking/presentation/pages/instant_service_page.dart';
import '../../features/booking/presentation/pages/schedule_service_page.dart';
import '../../features/artisan_home/presentation/pages/job_detail_page.dart';
import '../../features/main_navigation/presentation/pages/artisan_main_navigation_page.dart';
import '../../features/profile/presentation/pages/job_history_page.dart';
import '../../features/location/presentation/pages/location_gate_page.dart';

/// Route paths - centralized route path definitions
class AppRoutes {
  static const String splash = '/';
  static const String userTypeSelection = '/user-type-selection';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String clientHome = '/client-home';
  static const String artisanHome = '/artisan-home';
  static const String jobDetail = '/job-detail';
  static const String serviceCategories = '/service-categories';
  static const String allArtisans = '/all-artisans';
  static const String searchResult = '/search-result';
  static const String artisanProfile = '/artisan-profile';
  static const String instantService = '/instant-service';
  static const String scheduleService = '/schedule-service';
  static const String bookings = '/bookings';
  static const String jobHistory = '/profile/job-history';
  static const String locationGate = '/location-gate';

  // Auth routes
  static const String login = '/auth/login';
  static const String personalInformation = '/auth/personal-information';
  static const String password = '/auth/password';
  static const String phoneVerification = '/auth/phone-verification';
  static const String serviceSelection = '/auth/service-selection';
  static const String profilePicture = '/auth/profile-picture';

  // Forgot Password routes
  static const String forgotPasswordEmail = '/auth/forgot-password/email';
  static const String forgotPasswordOtp = '/auth/forgot-password/otp';
  static const String forgotPasswordNewPassword =
      '/auth/forgot-password/new-password';
}

/// Router configuration provider
/// This provides the GoRouter instance that will be used throughout the app
final routerProvider = Provider<GoRouter>((ref) {
  final tokenStorage = TokenStorageService();

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true, // Enable for debugging routes
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // User Type Selection (First onboarding screen)
      GoRoute(
        path: AppRoutes.userTypeSelection,
        name: 'userTypeSelection',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UserTypeSelectionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Onboarding Carousel
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) {
          final userType = state.extra as UserType;

          return CustomTransitionPage(
            key: state.pageKey,
            child: OnboardingCarouselPage(userType: userType),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
          );
        },
      ),

      // Home Page
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Client Home Page
      GoRoute(
        path: AppRoutes.clientHome,
        name: 'clientHome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainNavigationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Artisan Home Page
      GoRoute(
        path: AppRoutes.artisanHome,
        name: 'artisanHome',
        pageBuilder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final initialIndex = tab == 'jobs' ? 1 : 0;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ArtisanMainNavigationPage(initialIndex: initialIndex),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Job Detail Page
      GoRoute(
        path: AppRoutes.jobDetail,
        name: 'jobDetail',
        pageBuilder: (context, state) {
          final job = state.extra;
          return CustomTransitionPage(
            key: state.pageKey,
            child: JobDetailPage(job: job),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
          );
        },
      ),

      // Service Categories Page
      GoRoute(
        path: AppRoutes.serviceCategories,
        name: 'serviceCategories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ServiceCategoriesPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      GoRoute(
        path: AppRoutes.allArtisans,
        name: 'allArtisans',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AllArtisansPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      GoRoute(
        path: AppRoutes.locationGate,
        name: 'locationGate',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, String>? ?? const {};
          final scope = args['scope'] ?? 'client';
          final nextRoute = args['nextRoute'] ?? AppRoutes.login;

          return CustomTransitionPage(
            key: state.pageKey,
            child: LocationGatePage(scope: scope, nextRoute: nextRoute),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Search Result Page
      GoRoute(
        path: AppRoutes.searchResult,
        name: 'searchResult',
        pageBuilder: (context, state) {
          final query =
              state.uri.queryParameters['query'] ??
              state.extra as String? ??
              '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: SearchResultPage(query: query),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Artisan Profile Page
      GoRoute(
        path: AppRoutes.artisanProfile,
        name: 'artisanProfile',
        pageBuilder: (context, state) {
          final artisan = state.extra as dynamic;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ArtisanProfilePage(artisan: artisan),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Instant Service Page
      GoRoute(
        path: AppRoutes.instantService,
        name: 'instantService',
        pageBuilder: (context, state) {
          final artisan = state.extra as dynamic;
          return CustomTransitionPage(
            key: state.pageKey,
            child: InstantServicePage(artisan: artisan),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Schedule Service Page
      GoRoute(
        path: AppRoutes.scheduleService,
        name: 'scheduleService',
        pageBuilder: (context, state) {
          final artisan = state.extra as dynamic;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ScheduleServicePage(artisan: artisan),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      GoRoute(
        path: AppRoutes.jobHistory,
        name: 'jobHistory',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const JobHistoryPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Auth Routes
      // Login Page
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Personal Information Page
      GoRoute(
        path: AppRoutes.personalInformation,
        name: 'personalInformation',
        pageBuilder: (context, state) {
          final userType = state.extra as UserType;

          return CustomTransitionPage(
            key: state.pageKey,
            child: PersonalInformationPage(userType: userType),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Password Page
      GoRoute(
        path: AppRoutes.password,
        name: 'password',
        pageBuilder: (context, state) {
          final userType = state.extra as UserType;

          return CustomTransitionPage(
            key: state.pageKey,
            child: PasswordPage(userType: userType),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Phone Verification Page
      GoRoute(
        path: AppRoutes.phoneVerification,
        name: 'phoneVerification',
        pageBuilder: (context, state) {
          final userType = state.extra as UserType;

          return CustomTransitionPage(
            key: state.pageKey,
            child: PhoneVerificationPage(userType: userType),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Service Selection Page
      GoRoute(
        path: AppRoutes.serviceSelection,
        name: 'serviceSelection',
        pageBuilder: (context, state) {
          final userType = state.extra as UserType;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ServiceSelectionPage(userType: userType),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Profile Picture Page
      GoRoute(
        path: AppRoutes.profilePicture,
        name: 'profilePicture',
        pageBuilder: (context, state) {
          final userType = state.extra as UserType;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ProfilePicturePage(userType: userType),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Forgot Password Routes
      // Forgot Password Email Page
      GoRoute(
        path: AppRoutes.forgotPasswordEmail,
        name: 'forgotPasswordEmail',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordEmailPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Forgot Password OTP Page
      GoRoute(
        path: AppRoutes.forgotPasswordOtp,
        name: 'forgotPasswordOtp',
        pageBuilder: (context, state) {
          final email = state.extra as String;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ForgotPasswordOtpPage(email: email),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      // Forgot Password New Password Page
      GoRoute(
        path: AppRoutes.forgotPasswordNewPassword,
        name: 'forgotPasswordNewPassword',
        pageBuilder: (context, state) {
          final email = state.extra as String;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ForgotPasswordNewPasswordPage(email: email),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
    ],

    // Redirect logic - authentication guards
    redirect: (context, state) async {
      final hasToken = await tokenStorage.hasToken();
      final currentPath = state.matchedLocation;

      final publicPaths = [
        AppRoutes.splash,
        AppRoutes.userTypeSelection,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.personalInformation,
        AppRoutes.password,
        AppRoutes.phoneVerification,
        AppRoutes.serviceSelection,
        AppRoutes.profilePicture,
        AppRoutes.forgotPasswordEmail,
        AppRoutes.forgotPasswordOtp,
        AppRoutes.forgotPasswordNewPassword,
      ];

      final isPublicPath = publicPaths.contains(currentPath);

      if (!hasToken && !isPublicPath) {
        return AppRoutes.splash;
      }

      if (hasToken &&
          (currentPath == AppRoutes.login ||
              currentPath == AppRoutes.personalInformation ||
              currentPath == AppRoutes.password ||
              currentPath == AppRoutes.phoneVerification ||
              currentPath == AppRoutes.serviceSelection ||
              currentPath == AppRoutes.profilePicture)) {
        final authAsync = ref.read(authProvider);
        final user = authAsync.value;
        if (user != null) {
          return user.role == UserRole.artisan
              ? AppRoutes.artisanHome
              : AppRoutes.clientHome;
        }
      }

      return null;
    },

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
});
