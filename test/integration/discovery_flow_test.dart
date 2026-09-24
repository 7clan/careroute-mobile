import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/app.dart';
import 'package:careroute_mobile/core/network/mock_backend/mock_database.dart';
import 'package:careroute_mobile/domain/entities/appointment.dart';
import 'package:careroute_mobile/presentation/providers/appointments_providers.dart';
import 'package:careroute_mobile/presentation/providers/favorites_providers.dart';
import 'package:careroute_mobile/presentation/providers/session_providers.dart';
import 'package:careroute_mobile/presentation/screens/doctors/doctor_detail_screen.dart';
import 'package:careroute_mobile/presentation/widgets/doctor_card.dart';

import '../helpers/test_container.dart';

/// Integration-style golden path:
///
/// boot → login with the demo account → browse providers → open a profile
/// → favorite it → request an appointment → verify it in the appointments
/// state. Everything runs against the real router, Riverpod wiring, Dio
/// pipeline and mock backend (zero latency) — the only seams overridden
/// are the platform storage plugins.
///
/// Timing note: Dio's response pipeline delivers via zone timers (its
/// receive-timeout watchdog), so every interaction that triggers a request
/// is followed by a time-advancing pump, not just microtask flushes.
void main() {
  // Advance fake time enough for request delivery timers to fire, then
  // flush the microtasks the delivered responses schedule.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump();
  }

  testWidgets('guest can sign in, discover, favorite and book', (
    WidgetTester tester,
  ) async {
    // A realistic phone viewport so the lazy list renders a screenful.
    tester.view.physicalSize = const Size(411, 891) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = createTestContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CareRouteApp(),
      ),
    );

    // 1. Boot: session restore finds nothing → router lands on login.
    await settle(tester);
    expect(find.text('Welcome back'), findsOneWidget);

    // 2. Sign in with the demo account.
    await tester.enterText(
      find.byType(TextFormField).at(0),
      MockDatabase.demoEmail,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      MockDatabase.demoPassword,
    );
    await tester.tap(find.text('Sign in'));
    await settle(tester);

    expect(container.read(sessionProvider).value, isNotNull);

    // 3. The discovery feed is visible with provider cards.
    await settle(tester);
    expect(find.text('Discover providers'), findsOneWidget);
    // Lazy ListView: a screenful of cards (3+), not the full dataset.
    expect(find.byType(DoctorCard), findsAtLeastNWidgets(3));

    // 4. Open the second provider profile — the first seeded doctor has
    // `isAcceptingNewPatients = false` (every 4th one does), and this flow
    // needs a bookable provider.
    final doctor = tester
        .widget<DoctorCard>(find.byType(DoctorCard).at(1))
        .doctor;
    await tester.tap(find.text(doctor.name));
    await settle(tester);
    // Material page transitions last 300ms — let the route settle so the
    // underlying list (with its own favorite buttons) goes offstage.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Weekly schedule'), findsOneWidget);

    // 5. Save the provider to favorites (optimistic update). Scope to the
    // detail screen — the discovery list below also has favorite buttons.
    expect(container.read(favoritesProvider).value, isEmpty);
    final detailFavorite = find.descendant(
      of: find.byType(DoctorDetailScreen),
      matching: find.byTooltip('Add to favorites'),
    );
    await tester.tap(detailFavorite);
    await tester.pump();
    expect(
      container.read(favoritesProvider).value,
      isNotEmpty,
      reason: 'favorite persisted locally',
    );

    // 6. Request an appointment: day is pre-selected, pick the first slot.
    await tester.tap(find.text('Request appointment'));
    await settle(tester);
    expect(find.text('Available times'), findsOneWidget);

    await tester.tap(find.byType(ChoiceChip).first);
    await tester.pump();

    // Submit the *sheet's* button (the detail bar has the same label).
    final sheetSubmit = find
        .descendant(
          of: find.byType(MaterialApp),
          matching: find.text('Request appointment'),
        )
        .last;
    // ensureVisible scrolls the position but render objects keep their old
    // offsets until a frame is pumped — pump BEFORE the tap, otherwise the
    // tap lands off-screen.
    await tester.ensureVisible(sheetSubmit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(sheetSubmit);
    await settle(tester);

    expect(find.text('Request sent'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await settle(tester);

    // 7. The appointment shows up in the appointments state.
    final appointments = container.read(appointmentsProvider).value;
    expect(appointments, hasLength(1));
    expect(appointments!.first.status, AppointmentStatus.pending);
    expect(appointments.first.doctorName, doctor.name);
  });
}
