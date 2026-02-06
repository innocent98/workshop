# API Integration Testing Guide

## Prerequisites
- Ensure you have a valid artisan account logged in
- Backend API should be running at: `https://8153-102-90-98-94.ngrok-free.app/api/v1`
- Valid authentication token in secure storage

## Quick Test Commands

### 1. Test Profile Endpoint
```bash
# Get your current auth token first (from app logs or secure storage)
export TOKEN="your_auth_token_here"

# Test profile fetch
curl -H "Authorization: Bearer $TOKEN" \
  https://8153-102-90-98-94.ngrok-free.app/api/v1/profiles/artisans/me
```

Expected Response:
```json
{
  "id": "uuid",
  "full_name": "John Doe",
  "profile_picture_url": "https://...",
  "availability_status": "available",
  "total_jobs_completed": 34,
  "average_rating": 4.5,
  ...
}
```

### 2. Test Availability Update
```bash
# Update to available
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"availability_status":"available"}' \
  https://8153-102-90-98-94.ngrok-free.app/api/v1/profiles/artisans/me/availability

# Update to offline
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"availability_status":"offline"}' \
  https://8153-102-90-98-94.ngrok-free.app/api/v1/profiles/artisans/me/availability
```

### 3. Test Wallet Endpoint
```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://8153-102-90-98-94.ngrok-free.app/api/v1/wallet/balance
```

Expected Response:
```json
{
  "total_earned": "5000.00",
  "pending_release": "1000.00",
  "total_jobs_completed": 34
}
```

## Manual App Testing

### Test 1: Profile Picture Display
1. Open the app and navigate to Artisan Home
2. **Expected**: Your profile picture should be visible in the header
3. **Fallback**: If no profile picture is set, should show default avatar

### Test 2: Initial Availability Status
1. Observe the availability toggle section
2. **Expected**: Shows current status from API ("You're online" or "You're offline")
3. **Expected**: Toggle switch reflects the current state

### Test 3: Availability Toggle - Success Flow
1. Tap the availability toggle switch
2. **Expected**: Switch changes immediately (optimistic update)
3. **Expected**: Loading indicator or disabled state during API call
4. **Expected**: Success snackbar appears ("You're now online/offline")
5. **Expected**: Status text updates
6. **Verify**: Close and reopen app - status should persist

### Test 4: Availability Toggle - Error Flow
1. Turn off device internet/wifi
2. Tap the availability toggle
3. **Expected**: Switch changes immediately
4. **Expected**: Error snackbar appears with network error message
5. **Expected**: Switch reverts to previous state (rollback)
6. Turn internet back on and retry

### Test 5: Stats Cards Display
1. Observe the two stat cards below availability toggle
2. **Expected**: "Total Earnings" shows formatted amount (₦ X,XXX)
3. **Expected**: "Completed Jobs" shows job count number
4. **Expected**: Values match what API returns

### Test 6: Loading States
1. Clear app cache/data and restart
2. **Expected**: Availability section shows skeleton loading
3. **Expected**: Stats cards show grey skeleton boxes
4. **Expected**: Smooth transition from loading to data

### Test 7: Error State - Profile
1. Simulate API error (use invalid token or backend down)
2. **Expected**: Availability section shows error state
3. **Expected**: "Status unavailable" message with red color
4. **Expected**: Refresh icon visible
5. Tap refresh icon
6. **Expected**: Retries API call

### Test 8: Error State - Wallet
1. Simulate wallet API error
2. **Expected**: Stats cards show "--" values
3. **Expected**: "Tap to retry" text appears
4. Tap on the error card
5. **Expected**: Retries API call

### Test 9: 403 Error (Non-Artisan)
1. Login as a client user (not artisan)
2. Navigate to home
3. **Expected**: Error message: "Only artisans can access profile"
4. **Expected**: Appropriate error handling

### Test 10: Rapid Toggle Switching
1. Quickly tap availability toggle multiple times
2. **Expected**: Only one API call should be in flight
3. **Expected**: No duplicate updates
4. **Expected**: UI remains consistent

## Debug Tips

### Enable Dio Logging
The app already has LogInterceptor enabled. Check console for:
```
[DIO] Request: GET /profiles/artisans/me
[DIO] Response: 200 OK
[DIO] Response Body: {...}
```

### Check Riverpod State
Add debug prints in providers:
```dart
@override
Future<ArtisanProfile> build() async {
  print('🔵 Fetching artisan profile...');
  final repository = ref.read(artisanProfileRepositoryProvider);
  final profile = await repository.getMyProfile();
  print('✅ Profile loaded: ${profile.fullName}');
  return profile;
}
```

### Common Issues & Solutions

**Issue**: Profile picture not showing
- Check if `profile_picture_url` is null in API response
- Verify URL is accessible (not localhost)
- Check network image error handler

**Issue**: Toggle not updating
- Verify token is valid
- Check API endpoint is correct
- Ensure artisan role in user profile
- Check console for Dio error logs

**Issue**: Stats showing "--"
- Verify wallet endpoint is accessible
- Check if user has wallet created
- Verify response format matches expected structure

**Issue**: "Only artisans can access" error
- Verify logged-in user has role: "artisan"
- Check backend role validation
- Ensure token includes correct claims

## Performance Testing

### Cold Start
1. Kill app completely
2. Launch app
3. **Expected**: Data loads within 2-3 seconds
4. **Expected**: Skeletons show immediately

### Hot Reload
1. Make code change and hot reload
2. **Expected**: State persists
3. **Expected**: No unnecessary API calls

### Network Speed
1. Throttle network to 3G
2. Test all features
3. **Expected**: Timeout after configured duration (from ApiConfig)
4. **Expected**: Proper error messages

## Automation Test Script (Optional)

```dart
testWidgets('Artisan home page loads profile data', (tester) async {
  // Mock the providers
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        artisanProfileProvider.overrideWith(() => MockArtisanProfileNotifier()),
        artisanWalletProvider.overrideWith(() => mockWalletFuture),
      ],
      child: MaterialApp(home: ArtisanHomePage()),
    ),
  );

  // Wait for loading to complete
  await tester.pumpAndSettle();

  // Verify profile picture is shown
  expect(find.byType(CircleAvatar), findsOneWidget);

  // Verify availability toggle is shown
  expect(find.byType(CustomSwitch), findsOneWidget);

  // Verify stats cards are shown
  expect(find.text('Total Earnings'), findsOneWidget);
  expect(find.text('Completed Jobs'), findsOneWidget);
});
```

## Acceptance Criteria Verification

- [x] Profile picture displays from API (with fallback)
- [x] Availability toggle shows current status
- [x] Availability toggle persists to backend
- [x] Success feedback on availability update
- [x] Error feedback with rollback on failure
- [x] Stats cards show real data from wallet API
- [x] Loading states for all async data
- [x] Error states with retry functionality
- [x] Follows clean architecture pattern
- [x] No compilation errors
- [x] Proper error handling (network, 401, 403, etc.)

## Sign-Off Checklist

- [ ] All 10 manual tests pass
- [ ] API endpoints return expected data
- [ ] Error scenarios handled gracefully
- [ ] Loading states appear correctly
- [ ] No console errors or warnings
- [ ] Code follows existing patterns
- [ ] Ready for code review
