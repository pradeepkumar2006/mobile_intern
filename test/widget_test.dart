import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:my_app/core/models/user_profile_model.dart';
import 'package:my_app/core/models/wallet_transaction_model.dart';
import 'package:my_app/core/services/user_profile_service.dart';
import 'package:my_app/core/services/wallet_service.dart';
import 'package:my_app/screens/main_navigation_screen.dart';
import 'package:my_app/screens/onboarding_welcome_screen.dart';
import 'package:my_app/screens/profile_setup_screen.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/screens/user_auth_screen.dart';
import 'package:my_app/widgets/floating_bottom_bar.dart';
import 'package:my_app/widgets/trylo_logo.dart';
import 'package:my_app/screens/creator_discover_screen.dart';
import 'package:my_app/screens/creator_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1x1 transparent PNG for tests
final List<int> _transparentPng = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
];

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('Stage 1: Discovery Screen displays Trylo brand logo', (WidgetTester tester) async {
    await tester.pumpWidget(const TryloApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(TryloLogo), findsWidgets);
    expect(find.text('trylo'), findsWidgets);
  });

  testWidgets('Stage 2: Onboarding Screen displays 100% Match avatars and clean Join buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingWelcomeScreen(),
      ),
    );

    expect(find.byType(OnboardingWelcomeScreen), findsOneWidget);
    expect(find.text('100% Match'), findsOneWidget);
    expect(find.textContaining('Find your preferences'), findsOneWidget);
    expect(find.text('Join as Creator'), findsOneWidget);
    expect(find.text('Join as User'), findsOneWidget);
    expect(find.text('Already have an account? Log In'), findsOneWidget);

    // Tap Join as Creator
    await tester.tap(find.text('Join as Creator'));
    await tester.pump();
    expect(find.textContaining('Join as Creator'), findsWidgets);
  });

  testWidgets('Stage 3: UserAuthScreen handles Mobile OTP and Email Password flows', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: UserAuthScreen(),
      ),
    );

    // === Mobile OTP-First Mode (No password) ===
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Get OTP'), findsOneWidget);
    expect(find.text('Password'), findsNothing);
    expect(find.text('Forgot Password?'), findsNothing);

    // Social & Account links
    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Explore Trylo as Guest'), findsOneWidget);

    // === Email Mode ===
    await tester.tap(find.text('Use Email instead'));
    await tester.pumpAndSettle();

    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Switch back to Mobile
    await tester.tap(find.text('Use Mobile OTP instead'));
    await tester.pumpAndSettle();

    // === Test Mobile OTP flow ===
    await tester.enterText(find.byType(TextField).first, '6379897924');
    await tester.pump();

    await tester.tap(find.text('Get OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Verification Code'), findsOneWidget);
    expect(find.textContaining('6379897924'), findsWidgets);
    expect(find.text('Verify & Proceed'), findsOneWidget);
    expect(find.textContaining('Resend in'), findsOneWidget);
    expect(find.text('Change Phone Number'), findsOneWidget);
  });

  testWidgets('Stage 4: MainNavigationScreen 4 tabs and floating bottom bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );

    // Floating bar is present
    expect(find.byType(FloatingBottomBar), findsOneWidget);

    // Tab 0: Creator Discover Screen (Sample Image match)
    expect(find.text('Discover Stories'), findsOneWidget);
    expect(find.text('Near you'), findsOneWidget);
    expect(find.text('Joe'), findsOneWidget);
    expect(find.textContaining('Olivia Fisher'), findsOneWidget);
    expect(find.text('(3km)'), findsOneWidget);

    // Switch to Tab 1: Chat List
    await tester.tap(find.byIcon(Icons.chat_bubble_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Active Matches'), findsOneWidget);
    expect(find.text('3 New'), findsOneWidget);

    // Switch to Tab 2: Wallet Screen
    await tester.tap(find.byIcon(Icons.account_balance_wallet_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Trylo Wallet'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('Reserved Balance'), findsOneWidget);
    expect(find.text('Add Money'), findsOneWidget);
    expect(find.text('Transaction History'), findsOneWidget);

    // Switch to Tab 3: Self Profile Screen
    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.textContaining('Alex Morgan'), findsOneWidget);
    expect(find.text('Settings & Preferences'), findsOneWidget);

    // Return to Tab 0: Discover
    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Discover Stories'), findsOneWidget);
  });

  test('Stage 5: UserProfileModel calculates age and verifies 18+ correctly', () {
    final now = DateTime.now();
    final adultDob = DateTime(now.year - 22, now.month, now.day);
    final underageDob = DateTime(now.year - 16, now.month, now.day);

    expect(UserProfileModel.calculateAge(adultDob), 22);
    expect(UserProfileModel.calculateAge(underageDob), 16);

    final profile = UserProfileModel(
      id: 'test_user_1',
      name: 'Ravi Kumar',
      dateOfBirth: adultDob,
      age: 22,
      gender: 'Man',
      bio: 'Loves nature and photography',
      country: 'India',
      city: 'Coimbatore',
      languages: ['Tamil', 'English'],
      interests: ['Photography', 'Music'],
      isProfileCompleted: true,
    );

    final json = profile.toJson();
    final restored = UserProfileModel.fromJson(json);

    expect(restored.name, 'Ravi Kumar');
    expect(restored.age, 22);
    expect(restored.isProfileCompleted, isTrue);
    expect(restored.languages, contains('Tamil'));
    expect(restored.interests, contains('Photography'));
  });

  testWidgets('Stage 6: ProfileSetupScreen renders all onboarding fields and controls',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await UserProfileService.instance.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSetupScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify key onboarding headings and sections
    expect(find.text('Set Up Your Presence'), findsOneWidget);
    expect(find.text('Tap to set Profile Photo'), findsOneWidget);
    expect(find.text('Photo Gallery'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('About You (Bio)'), findsOneWidget);
    expect(find.text('Languages Spoken'), findsOneWidget);
    expect(find.text('Interests & Passions'), findsOneWidget);
    expect(find.text('Complete Profile & Continue'), findsOneWidget);

    // Verify gender choice chips
    expect(find.text('Woman'), findsWidgets);
    expect(find.text('Man'), findsWidgets);

    // Verify languages chips
    expect(find.text('Tamil'), findsWidgets);
    expect(find.text('English'), findsWidgets);

    // Verify interest chips
    expect(find.text('Coffee'), findsWidgets);
    expect(find.text('Music'), findsWidgets);
  });

  test('Stage 7: India-First Wallet balances, limits, Razorpay deposit, and refund flow',
      () async {
    SharedPreferences.setMockInitialValues({});
    final wallet = WalletService.instance;
    await wallet.init();

    // 1. Math verification: Total = Available + Reserved
    expect(wallet.totalBalance, wallet.availableBalance + wallet.reservedBalance);

    // 2. Minimum deposit limit (RBI compliance angle: Min ₹50)
    final minDepositResult = await wallet.depositFunds(
      amount: 25.0,
      paymentMethod: 'UPI - PhonePe',
    );
    expect(minDepositResult['success'], isFalse);
    expect(minDepositResult['message'], contains('Minimum deposit'));

    // 3. Maximum wallet balance limit (RBI PPI angle: Max ₹10,000)
    final excessDepositResult = await wallet.depositFunds(
      amount: 15000.0,
      paymentMethod: 'UPI - Google Pay',
    );
    expect(excessDepositResult['success'], isFalse);
    expect(excessDepositResult['message'], contains('RBI PPI'));

    // 4. Successful deposit via Razorpay UPI
    final initialAvail = wallet.availableBalance;
    final depositResult = await wallet.depositFunds(
      amount: 500.0,
      paymentMethod: 'UPI - PhonePe',
    );
    expect(depositResult['success'], isTrue);
    expect(wallet.availableBalance, initialAvail + 500.0);

    final txn = depositResult['transaction'] as WalletTransactionModel;
    expect(txn.paymentMethod, 'UPI - PhonePe');
    expect(txn.razorpayPaymentId, isNotNull);
    expect(txn.baseAmount + txn.gstAmount, closeTo(500.0, 0.1));
    expect(txn.invoiceId, startsWith('INV-2026-09-'));

    // 5. Booking Hold and Refund Flow (Requirement 7)
    final beforeHoldAvail = wallet.availableBalance;
    final beforeHoldReserved = wallet.reservedBalance;

    final holdSuccess = await wallet.holdForBooking(
      amount: 200.0,
      sessionTitle: 'Video Date with Host',
    );
    expect(holdSuccess, isTrue);
    expect(wallet.availableBalance, beforeHoldAvail - 200.0);
    expect(wallet.reservedBalance, beforeHoldReserved + 200.0);

    // Cancel Session -> Automatic Refund back to available balance
    final refundSuccess = await wallet.refundReservedBooking(
      amount: 200.0,
      sessionTitle: 'Video Date with Host',
    );
    expect(refundSuccess, isTrue);
    expect(wallet.availableBalance, beforeHoldAvail);
    expect(wallet.reservedBalance, beforeHoldReserved);

    // 6. Transaction filtering by time and type
    final depositsList = wallet.getFilteredTransactions(typeFilter: 'deposits');
    expect(depositsList.every((t) => t.type == WalletTransactionType.deposit), isTrue);

    final refundsList = wallet.getFilteredTransactions(typeFilter: 'refunds');
    expect(refundsList.every((t) => t.type == WalletTransactionType.refund), isTrue);
  });

  testWidgets('Stage 8: Creator Discover Screen search, filters, and Detailed Profile Rate Card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await WalletService.instance.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: CreatorDiscoverScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Top Bar, Country Selector, and Categories
    expect(find.text('Global'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Live Now'), findsOneWidget);

    // 2. Live Search test
    final searchInput = find.byType(TextField).first;
    await tester.enterText(searchInput, 'Sophia');
    await tester.pumpAndSettle();

    expect(find.textContaining('Sophia Chen'), findsOneWidget);
    expect(find.textContaining('Olivia Fisher'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('Olivia Fisher'), findsOneWidget);

    // 3. Category Tab: Live Now filter
    await tester.tap(find.text('Live Now'));
    await tester.pumpAndSettle();
    // Only online creators shown
    expect(find.textContaining('Maya Patel'), findsOneWidget);
    expect(find.textContaining('Liam Vance'), findsNothing);

    // Return to Featured
    await tester.tap(find.text('Featured'));
    await tester.pumpAndSettle();

    // 4. Open Advanced Filters Bottom Sheet
    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Filter Creators'), findsOneWidget);
    expect(find.text('Spoken Languages'), findsOneWidget);
    expect(find.text('Tamil'), findsWidgets);
    expect(find.text('Creator Gender'), findsOneWidget);
    expect(find.text('Verified Creators Only'), findsOneWidget);
    expect(find.text('Online Now Only'), findsOneWidget);

    // Close sheet
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    // 5. Navigate to Detailed Creator Profile Screen (PDF Page 9 & 10)
    final bookSessionButton = find.text('Book • From ₹200').first;
    await tester.tap(bookSessionButton);
    await tester.pumpAndSettle();

    expect(find.byType(CreatorDetailScreen), findsOneWidget);
    expect(find.text('Service Rate Card'), findsOneWidget);

    // Verify 4 Service Rate Card items specified in PDF Page 10
    expect(find.text('Paid Photo'), findsOneWidget);
    expect(find.text('₹200'), findsWidgets);

    expect(find.text('Paid Video'), findsOneWidget);
    expect(find.text('₹400'), findsOneWidget);

    expect(find.text('Voice Call'), findsOneWidget);
    expect(find.text('₹300'), findsOneWidget);

    expect(find.text('Video Call (10 Minutes)'), findsOneWidget);
    expect(find.text('₹500'), findsWidgets);

    // Sticky Bottom Bar
    expect(find.text('Start Chat'), findsOneWidget);
    expect(find.text('Book • ₹500'), findsOneWidget);

    // Test booking modal
    await tester.tap(find.text('Book • ₹500'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Booking Request'), findsOneWidget);
    expect(find.text('Selected Service'), findsOneWidget);
    expect(find.text('Available Wallet Balance'), findsOneWidget);
    expect(find.textContaining('will be locked in your Reserved Balance'), findsOneWidget);
  });
}

