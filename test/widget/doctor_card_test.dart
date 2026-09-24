import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/domain/entities/doctor.dart';
import 'package:careroute_mobile/presentation/widgets/doctor_card.dart';

import '../helpers/test_container.dart';

const _doctor = Doctor(
  id: 'd1',
  name: 'Layal Haddad',
  specialtyId: 'family-medicine',
  specialtyName: 'Family Medicine',
  city: 'Beirut',
  address: 'Rue Spears, Beirut',
  rating: 4.7,
  reviewCount: 128,
  experienceYears: 12,
  consultationFee: 45,
  languages: ['Arabic', 'English'],
  education: ['MD — AUB'],
  bio: 'Calm and thorough.',
  photoUrl: 'https://i.pravatar.cc/300?img=4',
  isAcceptingNewPatients: true,
);

Future<SemanticsHandle> _pumpCard(
  WidgetTester tester,
  VoidCallback onTap,
) async {
  final handle = tester.ensureSemantics();
  final container = createTestContainer();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [DoctorCard(doctor: _doctor, onTap: onTap)],
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  return handle;
}

void main() {
  group('DoctorCard', () {
    testWidgets('renders name, specialty, city and fee', (tester) async {
      final handle = await _pumpCard(tester, () {});

      expect(find.text('Layal Haddad'), findsOneWidget);
      expect(find.text('Family Medicine'), findsOneWidget);
      expect(find.text('Beirut'), findsOneWidget);
      expect(find.text(r'$45 consultation'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('taps invoke the callback', (tester) async {
      var taps = 0;
      final handle = await _pumpCard(tester, () => taps++);

      await tester.tap(find.text('Layal Haddad'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('exposes one merged semantics node for screen readers', (
      tester,
    ) async {
      final handle = await _pumpCard(tester, () {});

      expect(
        find.bySemanticsLabel(
          RegExp('Layal Haddad, Family Medicine, rating 4.7 out of 5'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('favorite button is a labelled, accessible toggle', (
      tester,
    ) async {
      final handle = await _pumpCard(tester, () {});

      expect(
        find.bySemanticsLabel('Save Layal Haddad to favorites'),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Save Layal Haddad to favorites'));
      await tester.pump();

      expect(
        find.bySemanticsLabel('Remove Layal Haddad from favorites'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
