import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careroute_mobile/presentation/screens/auth/login_screen.dart';
import 'package:careroute_mobile/presentation/screens/doctors/doctors_screen.dart';
import 'package:careroute_mobile/presentation/widgets/skeleton_tile.dart';

import '../helpers/test_container.dart';

/// Accessibility contract tests: semantics labels, touch-target sizes and
/// layout survival at large text scales. These encode the guarantees the
/// docs claim — they fail when a regression lands.
void main() {
  group('touch targets', () {
    testWidgets('icon-only buttons are at least 48x48 logical pixels', (
      tester,
    ) async {
      final container = createTestContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DoctorsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      final violations = <String>[];
      for (final element in find.byType(IconButton).evaluate()) {
        final box = element.renderObject as RenderBox;
        if (box.size.width < 48 || box.size.height < 48) {
          violations.add('IconButton is ${box.size.width}x${box.size.height}');
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('text scaling', () {
    Future<void> pumpAtScale(
      WidgetTester tester,
      Widget child,
      double scale,
    ) async {
      final container = createTestContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: child,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
    }

    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('doctors screen renders without overflow at ${scale}x text', (
        tester,
      ) async {
        // A realistic phone viewport (411 x 891 logical pixels).
        tester.view.physicalSize = const Size(411, 891) * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpAtScale(tester, const DoctorsScreen(), scale);
        expect(
          tester.takeException(),
          isNull,
          reason: 'layout must flex instead of overflowing',
        );
        // ListView.builder renders lazily and taller text at large
        // scales fits fewer cards on screen — assert cards are visible,
        // not a fixed count. The overflow check above is the contract.
        expect(find.byType(Card), findsAtLeastNWidgets(1));
      });

      testWidgets('login screen renders without overflow at ${scale}x text', (
        tester,
      ) async {
        await pumpAtScale(tester, const LoginScreen(), scale);
        expect(tester.takeException(), isNull);
        expect(find.text('Welcome back'), findsOneWidget);
      });
    }
  });

  group('semantics', () {
    testWidgets('form errors are announced (live region on error banners)', (
      tester,
    ) async {
      final container = createTestContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Trigger server-mapped form-level errors with wrong credentials.
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
      await tester.enterText(find.byType(TextFormField).at(1), 'WrongPass1');
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      // The error banner we render wraps its text in a live-region
      // semantics node so screen readers announce the failure.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.liveRegion == true,
        ),
        findsOneWidget,
      );
      expect(
        find.text('These credentials do not match our records.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'loading skeletons are announced as a unit and hidden from readers',
      (tester) async {
        // Isolate the widget: the whole-screen test below covers layout;
        // here the contract is purely about the semantics tree.
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            const MaterialApp(home: Scaffold(body: DoctorListSkeleton())),
          );
          await tester.pump(); // start shimmer animations

          // One merged node announces the loading state…
          expect(find.bySemanticsLabel('Loading providers'), findsOneWidget);

          // …and nothing else is readable: the decorative tiles expose no
          // labels of their own (ExcludeSemantics in SkeletonTile).
          // Reached via the render views' pipeline owner (the
          // non-deprecated path, unlike BindingBase.pipelineOwner).
          final owner = tester.binding.renderViews.first.owner;
          final labels = <String>[];
          void collect(SemanticsNode node) {
            if (node.label.isNotEmpty) labels.add(node.label);
            bool visitChild(SemanticsNode child) {
              collect(child);
              return true; // keep visiting siblings
            }

            node.visitChildren(visitChild);
          }

          final root = owner?.semanticsOwner?.rootSemanticsNode;
          expect(root, isNotNull, reason: 'semantics must be enabled');
          collect(root!);
          expect(labels, ['Loading providers']);
        } finally {
          handle.dispose();
        }
      },
    );
  });
}
