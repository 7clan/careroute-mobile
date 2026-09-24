import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/core/network/mock_backend/backend_conditions.dart';
import 'package:careroute_mobile/presentation/providers/infrastructure_providers.dart';
import 'package:careroute_mobile/presentation/screens/doctors/doctors_screen.dart';

import '../helpers/test_container.dart';

void main() {
  Future<ProviderContainer> pumpDoctors(
    WidgetTester tester, {
    BackendConditions conditions = const BackendConditions(
      latency: Duration.zero,
    ),
  }) async {
    // A realistic phone viewport so assertions match real rendering.
    tester.view.physicalSize = const Size(411, 891) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = createTestContainer(conditions: conditions);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DoctorsScreen()),
      ),
    );
    // Plain pumps flush frames/microtasks; advancing fake time lets the
    // Dio response streams deliver (FakeAsync quirk of the test zone).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    return container;
  }

  group('DoctorsScreen states', () {
    testWidgets('renders provider cards after loading', (tester) async {
      await pumpDoctors(tester);

      // Lazy ListView: assert a screenful of cards, not the full dataset.
      expect(find.byType(Card), findsAtLeastNWidgets(3));
      // Result count reflects the seeded dataset.
      expect(find.text('72 found'), findsOneWidget);
    });

    testWidgets('search narrows the list (server-side filtering)', (
      tester,
    ) async {
      await pumpDoctors(tester);

      await tester.enterText(find.byType(TextField).first, 'cardiology');
      // Debounce window (350ms) must elapse before the query commits.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();

      expect(find.text('6 found'), findsOneWidget);
    });

    testWidgets('no matches render the empty state with a clear action', (
      tester,
    ) async {
      await pumpDoctors(tester);

      await tester.enterText(find.byType(TextField).first, 'zzz-no-match');
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump();

      expect(find.text('No providers found'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('API failures render the error state and retry recovers', (
      tester,
    ) async {
      final container = await pumpDoctors(
        tester,
        conditions: const BackendConditions(
          latency: Duration.zero,
          forceStatus: 500,
        ),
      );

      expect(find.byType(ListView), findsNothing);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      // Recover the backend (keep zero latency) and retry.
      container
          .read(backendConditionsProvider.notifier)
          .setForceServerError(false);
      await tester.tap(find.text('Try again'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.byType(Card), findsAtLeastNWidgets(3));
    });

    testWidgets('specialty chips render from the specialties API', (
      tester,
    ) async {
      await pumpDoctors(tester);

      // The chip row is a lazily built horizontal list — later chips are
      // only materialised once scrolled into view.
      // (find.ancestor can yield duplicate entries for shared ancestors,
      // hence `.first`.)
      final chipRow = find
          .ancestor(
            of: find.byType(FilterChip),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Pediatrics'),
        120,
        scrollable: chipRow,
      );

      expect(find.text('Family Medicine'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Dentistry'),
        120,
        scrollable: chipRow,
      );
      expect(find.text('Dentistry'), findsOneWidget);
    });
  });
}
