# GoRouter Implementation Guide

## Overview

This project uses **go_router** for declarative, type-safe navigation throughout the app. All routing configuration is centralized in `lib/core/routes/app_router.dart`.

## Benefits of GoRouter

✅ **Declarative routing** - All routes defined in one place
✅ **Type-safe navigation** - No magic strings
✅ **Deep linking support** - Works with web URLs and app links
✅ **Built-in redirects** - Easy authentication guards
✅ **Custom transitions** - Beautiful page transitions
✅ **Web-friendly** - Excellent browser back button support
✅ **Riverpod integration** - State management ready

## File Structure

```
lib/
├── core/
│   └── routes/
│       └── app_router.dart          # Centralized routing configuration
├── features/
│   ├── splash/
│   │   └── presentation/pages/
│   │       └── splash_page.dart     # Uses: context.go()
│   ├── onboarding/
│   │   └── presentation/pages/
│   │       ├── user_type_selection_page.dart  # Uses: context.push()
│   │       └── onboarding_carousel_page.dart  # Uses: context.go()
│   └── home/
│       └── presentation/pages/
│           └── home_page.dart
└── main.dart                        # MaterialApp.router setup
```

## Route Definitions

All route paths are defined in `AppRoutes` class:

```dart
class AppRoutes {
  static const String splash = '/';
  static const String userTypeSelection = '/user-type-selection';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
}
```

## Navigation Flow

```
Splash Screen (/)
    ↓ context.go()
User Type Selection (/user-type-selection)
    ↓ context.push() with UserType extra
Onboarding Carousel (/onboarding)
    ↓ context.go()
Home Page (/home)
```

## How to Navigate

### 1. **Simple Navigation (Replace current route)**
```dart
context.go(AppRoutes.home);
```
- Replaces the current route in the navigation stack
- Use for: completing onboarding, logout, etc.

### 2. **Push Navigation (Keep history)**
```dart
context.push(AppRoutes.onboarding);
```
- Adds route to navigation stack
- User can press back to return
- Use for: navigating to detail pages, forms, etc.

### 3. **Navigation with Parameters**
```dart
// Pass data using 'extra'
context.push(AppRoutes.onboarding, extra: UserType.artisan);

// Receive data in route definition
pageBuilder: (context, state) {
  final userType = state.extra as UserType;
  return OnboardingCarouselPage(userType: userType);
}
```

### 4. **Named Route Navigation**
```dart
// Using route name instead of path
context.pushNamed('onboarding', extra: UserType.client);
context.goNamed('home');
```

### 5. **Pop/Go Back**
```dart
// Simple back navigation
context.pop();

// Back with result
context.pop(resultData);
```

## Custom Page Transitions

All routes use `CustomTransitionPage` for smooth transitions:

### Fade Transition (Splash, Home)
```dart
CustomTransitionPage(
  key: state.pageKey,
  child: const SplashPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(opacity: animation, child: child);
  },
)
```

### Slide + Fade Transition (Onboarding)
```dart
CustomTransitionPage(
  key: state.pageKey,
  child: OnboardingCarouselPage(userType: userType),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(opacity: animation, child: child),
    );
  },
)
```

## Authentication Guards (Ready for Implementation)

The router has a `redirect` function ready for authentication:

```dart
redirect: (context, state) {
  // 1. Get authentication state from Riverpod
  final isAuthenticated = ref.read(authProvider).isAuthenticated;

  // 2. Define public pages
  final isOnAuthPage = state.matchedLocation == AppRoutes.splash ||
                       state.matchedLocation == AppRoutes.userTypeSelection;

  // 3. Redirect unauthenticated users to splash
  if (!isAuthenticated && !isOnAuthPage) {
    return AppRoutes.splash;
  }

  // 4. Redirect authenticated users away from auth pages
  if (isAuthenticated && isOnAuthPage) {
    return AppRoutes.home;
  }

  return null; // No redirect needed
},
```

### How to Implement Authentication Later:

1. **Create Auth Provider** (`lib/features/auth/providers/auth_provider.dart`):
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final User? user;

  AuthState({this.isAuthenticated = false, this.user});
}
```

2. **Update Router to Use Auth Provider**:
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    // ... routes
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      // ... redirect logic
    },
    refreshListenable: // Auto-refresh when auth changes
  );
});
```

## Adding New Routes

### Step 1: Define the route path
```dart
class AppRoutes {
  // ... existing routes
  static const String profile = '/profile';
  static const String jobDetails = '/jobs/:id';  // With path parameter
}
```

### Step 2: Add route to router configuration
```dart
GoRoute(
  path: AppRoutes.profile,
  name: 'profile',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const ProfilePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
),
```

### Step 3: Navigate to the route
```dart
// From anywhere in your app
context.push(AppRoutes.profile);
```

## Route Parameters

### Path Parameters
```dart
// Route definition
GoRoute(
  path: '/jobs/:id',
  name: 'jobDetails',
  pageBuilder: (context, state) {
    final jobId = state.pathParameters['id']!;
    return CustomTransitionPage(
      child: JobDetailsPage(jobId: jobId),
      // ...
    );
  },
),

// Navigate
context.push('/jobs/123');
```

### Query Parameters
```dart
// Route definition
GoRoute(
  path: '/search',
  name: 'search',
  pageBuilder: (context, state) {
    final query = state.uri.queryParameters['q'];
    return CustomTransitionPage(
      child: SearchPage(query: query),
      // ...
    );
  },
),

// Navigate
context.push('/search?q=plumber&location=lagos');
```

## Deep Linking

GoRouter automatically handles deep links. Configure in platform-specific files:

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="https"
    android:host="workshop.app" />
</intent-filter>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>workshop</string>
    </array>
  </dict>
</array>
```

Then URLs like `https://workshop.app/jobs/123` will automatically route to the correct page!

## Best Practices

### ✅ DO:
- Use `context.go()` for completing flows (onboarding, logout)
- Use `context.push()` for stackable navigation (details, forms)
- Define all paths in `AppRoutes` class
- Use named routes for better maintainability
- Pass data using `extra` parameter
- Use path parameters for IDs: `/jobs/:id`

### ❌ DON'T:
- Don't use hardcoded strings: ❌ `context.go('/home')`
- Don't use Navigator directly: ❌ `Navigator.push()`
- Don't mix Navigator and GoRouter
- Don't forget to handle `extra` data type casting

## Debugging Routes

Enable debug logging in router configuration:
```dart
GoRouter(
  debugLogDiagnostics: true,  // Shows route changes in console
  // ...
)
```

## Testing Navigation

```dart
testWidgets('Navigation test', (tester) async {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [/* ... */],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );

  // Test navigation
  router.go(AppRoutes.home);
  await tester.pumpAndSettle();

  expect(find.byType(HomePage), findsOneWidget);
});
```

## Migration from Navigator to GoRouter

We've successfully migrated from manual Navigator to GoRouter:

### Before (Manual Navigation)
```dart
Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
      const UserTypeSelectionPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 500),
  ),
);
```

### After (GoRouter)
```dart
context.go(AppRoutes.userTypeSelection);
```

**Result**: 90% less boilerplate code! 🎉

## Resources

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Guide](https://docs.flutter.dev/ui/navigation)
- [GoRouter + Riverpod](https://codewithandrea.com/articles/flutter-navigation-gorouter-riverpod/)

## Support

For questions or issues with routing, check:
1. Route is defined in `app_router.dart`
2. Path is correct in `AppRoutes`
3. Navigation context is available
4. Extra data is properly typed

Happy routing! 🚀
