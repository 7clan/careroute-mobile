import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/presentation/providers/session_providers.dart';
import 'package:careroute_mobile/presentation/screens/auth/login_screen.dart';

import '../helpers/test_container.dart';

void main() {
  Future<ProviderContainer> pumpLogin(WidgetTester tester) async {
    final container = createTestContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    return container;
  }

  group('LoginScreen', () {
    testWidgets('renders the brand and form', (tester) async {
      await pumpLogin(tester);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('validates empty fields with accessible inline errors', (
      tester,
    ) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please choose a password.'), findsOneWidget);
    });

    testWidgets('rejects malformed input before hitting the API', (
      tester,
    ) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(
        find.text('Enter a valid email, e.g. name@mail.com.'),
        findsOneWidget,
      );
    });

    testWidgets('wrong credentials show a mapped, non-technical error', (
      tester,
    ) async {
      await pumpLogin(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        MockDatabase.demoEmail,
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'WrongPass1');
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(
        find.text('These credentials do not match our records.'),
        findsOneWidget,
        reason: 'must map the 401 into the API message, not raw Dio output',
      );
    });

    testWidgets('the demo prefill button fills both fields', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Use demo account'));
      await tester.pump();

      expect(
        (tester.widget(
          find.byType(TextFormField).at(0),
        ) as TextFormField).controller!.text,
        MockDatabase.demoEmail,
      );
      expect(
        (tester.widget(
          find.byType(TextFormField).at(1),
        ) as TextFormField).controller!.text,
        MockDatabase.demoPassword,
      );
    });

    testWidgets('signing in with the demo account updates the session state', (
      tester,
    ) async {
      final container = await pumpLogin(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        MockDatabase.demoEmail,
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        MockDatabase.demoPassword,
      );
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      final session = container.read(sessionProvider).value;
      expect(session, isNotNull);
      expect(session?.user.email, MockDatabase.demoEmail);
    });

    testWidgets('password visibility toggle carries a semantic label', (
      tester,
    ) async {
      await pumpLogin(tester);

      expect(find.bySemanticsLabel('Show password'), findsOneWidget);

      await tester.tap(find.byTooltip('Show'));
      await tester.pump();

      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
    });
  });
}
