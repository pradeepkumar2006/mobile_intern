import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/services/user_profile_service.dart';
import 'package:my_app/core/services/wallet_service.dart';
import 'package:my_app/screens/profile_self_screen.dart';
import 'package:my_app/screens/user_settings_screen.dart';
import 'package:my_app/widgets/post_session_review_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final mockCreator = {
    'id': 'cr_olivia',
    'name': 'Olivia Fisher',
    'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    'rate': 500,
  };

  testWidgets('Requirement 5: PostSessionReviewSheet renders rating stars, tags, review box, and submit feedback',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await WalletService.instance.init();

    bool completedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostSessionReviewSheet(
            creator: mockCreator,
            serviceTitle: 'Video Call (10 Minutes)',
            sessionCost: 500.0,
            onCompleted: () {
              completedCalled = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify creator header
    expect(find.textContaining('Rate Your Session with Olivia Fisher'), findsOneWidget);
    expect(find.textContaining('Video Call (10 Minutes) • ₹500 Settled'), findsOneWidget);

    // Verify star rating
    expect(find.byIcon(Icons.star_rounded), findsWidgets);
    expect(find.text('Exceptional Experience! ⭐'), findsOneWidget);

    // Tap 4th star to test interaction
    await tester.tap(find.byIcon(Icons.star_rounded).at(3));
    await tester.pumpAndSettle();
    expect(find.text('Great Conversation'), findsWidgets);

    // Verify quick tag chips
    expect(find.text('Polite Host'), findsOneWidget);
    expect(find.text('Clear Audio'), findsOneWidget);
    expect(find.text('Helpful Advice'), findsOneWidget);

    // Toggle a tag
    await tester.tap(find.text('Clear Audio'));
    await tester.pumpAndSettle();

    // Verify optional review text box
    expect(find.text('Add a written review (Optional)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Wonderful session! Loved the talk.');
    await tester.pumpAndSettle();

    // Verify Submit Feedback button
    expect(find.text('Submit Feedback'), findsOneWidget);

    // Tap Tip button (+₹50)
    await tester.tap(find.text('+₹50'));
    await tester.pumpAndSettle();
    expect(find.text('Submit Feedback & Tip ₹50'), findsOneWidget);

    // Revert tip to None
    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();
    expect(find.text('Submit Feedback'), findsOneWidget);

    // Submit Feedback
    await tester.tap(find.text('Submit Feedback'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(completedCalled, isTrue);
  });

  testWidgets('Requirement 6: UserSettingsScreen renders all 4 dedicated gradient tabs and sections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: UserSettingsScreen(initialIndex: 0),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Top Header Bar & Tabs
    expect(find.text('Settings & Security'), findsOneWidget);
    expect(find.text('Privacy & Safety'), findsWidgets);
    expect(find.text('Notifications'), findsWidgets);
    expect(find.text('KYC & Limits'), findsWidgets);
    expect(find.text('Dispute & Support'), findsWidgets);

    // Tab 1: Privacy & Safety
    expect(find.text('Privacy & Safety Shield'), findsOneWidget);
    expect(find.text('Hide Online Status'), findsOneWidget);
    expect(find.text('Message Read Receipts'), findsOneWidget);
    expect(find.textContaining('Blocked Accounts'), findsOneWidget);
    expect(find.text('Rahul Verma'), findsOneWidget);
    expect(find.text('Sneha Kapoor'), findsOneWidget);
    expect(find.text('Arjun Dev'), findsOneWidget);
    expect(find.text('Unblock'), findsWidgets);

    // Test toggle Hide Online Status
    await tester.tap(find.text('Hide Online Status'));
    await tester.pumpAndSettle();

    // Test Unblock dialog
    await tester.tap(find.text('Unblock').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Unblock Rahul Verma?'), findsOneWidget);
    // Confirm unblock
    final confirmUnblock = find.widgetWithText(ElevatedButton, 'Unblock');
    await tester.tap(confirmUnblock);
    await tester.pumpAndSettle();
    expect(find.text('Rahul Verma'), findsNothing);

    // Switch to Tab 2: Notifications
    await tester.tap(find.text('Notifications').first);
    await tester.pumpAndSettle();

    expect(find.text('Notification Hub'), findsOneWidget);
    expect(find.text('Session Booking & Acceptance'), findsOneWidget);
    expect(find.text('Creator Online Alerts'), findsOneWidget);
    expect(find.text('Wallet Deposit Success'), findsOneWidget);
    expect(find.text('Save Notification Preferences'), findsOneWidget);

    // Test saving preferences
    await tester.ensureVisible(find.text('Save Notification Preferences'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Notification Preferences'));
    await tester.pumpAndSettle();

    // Switch to Tab 3: KYC & Limits Center
    await tester.tap(find.text('KYC & Limits').first);
    await tester.pumpAndSettle();

    expect(find.text('KYC & Limits Center'), findsOneWidget);
    expect(find.textContaining('₹10,000 Limit (Minimum KYC)'), findsOneWidget);
    expect(find.textContaining('RBI Master Direction on PPIs'), findsOneWidget);

    await tester.ensureVisible(find.text('Verify via DigiLocker (Instant)'));
    await tester.pumpAndSettle();

    expect(find.text('Submit Government ID Details'), findsOneWidget);
    expect(find.text('12-Digit Aadhaar Number'), findsOneWidget);
    expect(find.text('10-Character PAN Number'), findsOneWidget);
    expect(find.text('Verify via DigiLocker (Instant)'), findsOneWidget);

    // Enter Aadhaar and PAN
    await tester.enterText(find.widgetWithText(TextFormField, '5421 8934 1029'), '987654321098');
    await tester.enterText(find.widgetWithText(TextFormField, 'ABCDE1234F'), 'ABCDE1234F');
    await tester.pumpAndSettle();

    // Tap DigiLocker verification button
    await tester.tap(find.text('Verify via DigiLocker (Instant)'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Verify upgrade confirmation
    expect(find.textContaining('Full KYC Approved!'), findsOneWidget);
    await tester.tap(find.text('Awesome!'));
    await tester.pumpAndSettle();

    expect(find.text('Full KYC Active & Compliant'), findsOneWidget);

    // Switch to Tab 4: Dispute & Support Center
    await tester.tap(find.text('Dispute & Support').first);
    await tester.pumpAndSettle();

    expect(find.text('Dispute & Support Desk'), findsOneWidget);
    expect(find.textContaining('Raise a Support Ticket'), findsOneWidget);
    expect(find.text('Issue Category'), findsOneWidget);
    expect(find.text('Explain What Happened'), findsOneWidget);
    expect(find.text('Urgency Level'), findsOneWidget);

    await tester.ensureVisible(find.text('Submit Support Ticket'));
    await tester.pumpAndSettle();

    expect(find.text('Submit Support Ticket'), findsOneWidget);

    // Fill and submit dispute ticket
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Provide details about call drop, payment discrepancy, or host behavior...'),
        'The call abruptly terminated at minute 4. Please investigate and refund.');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Support Ticket'));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.textContaining('created! Our trust team will contact you.'), findsOneWidget);
  });

  testWidgets('Requirement 6: ProfileSelfScreen links to UserSettingsScreen sections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await UserProfileService.instance.init();
    await WalletService.instance.init();

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSelfScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify menu items
    expect(find.text('Privacy & Safety'), findsOneWidget);
    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('KYC & Limits Center'), findsOneWidget);
    expect(find.text('Support & Dispute Center'), findsOneWidget);

    // Tap KYC & Limits Center
    await tester.tap(find.text('KYC & Limits Center'));
    await tester.pumpAndSettle();

    expect(find.byType(UserSettingsScreen), findsOneWidget);
    expect(find.text('KYC & Limits Center'), findsOneWidget);
    expect(find.textContaining('₹10,000 Limit'), findsOneWidget);
  });
}
