// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_link/app.dart';
import 'package:nexus_link/core/constants/app_strings.dart';
import 'package:nexus_link/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('App launches and displays title, then transitions to the menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NexusLinkApp());
    await tester.pump();

    expect(find.text(AppStrings.appName.toUpperCase()), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump();

    expect(find.text('START GAME'), findsOneWidget);
  });

  testWidgets(
    'Invalid level shows recovery actions instead of infinite loading',
    (WidgetTester tester) async {
      await tester.pumpWidget(const NexusLinkApp());
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();

      tester
          .element(find.text('START GAME'))
          .read<NavigationProvider>()
          .goToGame('missing_level');
      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to load this level'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);
      expect(find.text('BACK TO LEVELS'), findsOneWidget);
    },
  );
}
