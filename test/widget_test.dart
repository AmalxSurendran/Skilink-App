import 'package:customer/view/screens/Onboboarding/onboarding_view.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:customer/main.dart';

void main() {
  testWidgets('Basic widget test for MyApp', (WidgetTester tester) async {
    // Initialize the dependencies
    await Firebase
        .initializeApp(); // Initialize Firebase for the test environment

    // Create a mock instance of FacebookAppEvents
    final facebookAppEvents = FacebookAppEvents();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      onboarding: false, // Pass the required parameter
      facebookAppEvents: facebookAppEvents,
    ));

    // Verify that the correct widget is displayed based on the onboarding parameter
    expect(find.byType(OnboardingView), findsOneWidget);

    // For example, you might want to verify the presence of specific widgets
    // if you are testing different widgets based on onboarding status.

    // If you had a counter or similar widget, you could test its behavior here.
    // For instance:
    // expect(find.text('0'), findsOneWidget);
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    // expect(find.text('1'), findsOneWidget);
  });
}
