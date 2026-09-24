# Testing

**131 tests, all passing** (`flutter test`, verified 2026-09-23). Every
category required by the spec is present: unit, repository/service, state,
widget, and an integration-style user flow.

## The pyramid

| Layer | Files | Count | What they prove |
| --- | --- | --- | --- |
| Pure unit | `test/core/` | 30+ | debouncer timing, validators, error mapping, mock-backend behavior (token expiry, validation, conditions) |
| Repository | `test/data/` | 20+ | repositories through the **real Dio pipeline** against the deterministic backend — status codes, timeouts, malformed JSON, offline |
| State | `test/providers/` | 30+ | controller logic: pagination, stale-response guards, debounce, optimistic favorites, session expiry flow |
| Widget | `test/widget/` | 20+ | screens render every state; accessibility contracts (semantics, touch targets, text scaling) |
| Integration | `test/integration/` | 1 | the full golden path |

## The test seam: `createTestContainer()`

`test/helpers/test_container.dart` builds an isolated `ProviderContainer`
per test with four overrides:

```dart
mockDatabaseProvider.overrideWithValue(MockDatabase.seeded()), // fresh world
keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
authLocalDataSourceProvider.overrideWith(InMemoryAuthLocalDataSource()),
backendConditionsProvider.overrideWith(FixedConditionsController(…)),
```

No platform plugins, no shared state, no network. The *app code under test
is the real app code* — only the edges are replaced. The same retry policy
as production (`retry: (_, _) => null`) is applied so errors surface
immediately.

## Repository tests run the real pipeline

Example — `test/data/doctor_repository_test.dart`:

```dart
final repository = DoctorRepositoryImpl(
  dio: createTestDio(conditions: const BackendConditions(forceStatus: 500)),
);
expectLater(
  repository.fetchDoctors(const DoctorQuery()),
  throwsA(isA<ServerException>()),
);
```

The request travels through Dio, the interceptor, the adapter, gets a real
HTTP-500-shaped response, and is mapped by `DioExceptionMapper` — the
exact production path. A mapper regression fails these tests.

## Widget tests assert behavior, not pixels

`test/widget/doctors_screen_test.dart` covers the state table — data,
search (including the 350 ms debounce window), empty state with clear
action, error state, **retry recovery** (the backend is healed via
`backendConditionsProvider.notifier.setForceServerError(false)` and "Try
again" is tapped — the list must return), and the specialty chip row
(scrolled into view, since it is a lazily built horizontal list).

## Accessibility is a test contract

`test/widget/accessibility_test.dart` encodes the a11y guarantees as
executable specs (details in [ACCESSIBILITY.md](ACCESSIBILITY.md)):

- icon-only buttons ≥ 48×48 logical px,
- no layout overflow at 1.0×/1.3×/2.0× text scale on both key screens,
- form error banners are semantics live regions (screen readers announce),
- the loading skeleton is announced as one unit and its decorative tiles
  are excluded from the semantics tree (verified by walking the
  `SemanticsNode` tree and asserting the label list is exactly
  `['Loading providers']`).

## Integration: the golden path

`test/integration/discovery_flow_test.dart` boots the **real app**
(`CareRouteApp` + real router + real Riverpod wiring + real Dio pipeline),
then: signs in with the demo account → verifies the feed → opens a
provider profile → favorites it (optimistic state asserted on the
container) → requests an appointment through the bottom sheet (day
pre-selected, first slot chosen) → confirms the success view → asserts the
appointment exists in `appointmentsProvider` with `pending` status and the
right doctor.

### Test-zone timing lessons (documented because they bit us)

Dio's response pipeline delivers via zone timers (its receive-timeout
watchdog), so in `FakeAsync` widget tests a plain `pump()` (microtasks
only) is **not** enough after an action that triggers a request — every
settle includes a time-advancing pump:

```dart
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120)); // fires timers
  await tester.pump();
}
```

Similarly, `tester.ensureVisible()` scrolls a position but render objects
keep stale offsets until a frame is pumped — pump **before** reading tap
coordinates. Both gotchas are commented in the test file.

## Running & gates

```bash
flutter test                     # 131 passed
flutter test test/integration    # just the golden path
flutter test --coverage          # coverage/lcov.info available on request
```

CI (`.github/workflows/flutter_ci.yml`) runs `pub get` → format check →
`flutter analyze` → `flutter test` on every push/PR.

## Extending the suite

- New repository: follow `test/data/doctor_repository_test.dart` —
  construct through `createTestDio`, assert domain exceptions.
- New controller: follow `test/providers/doctors_controller_test.dart` —
  `createTestContainer`, drive the notifier, assert state transitions.
- New screen: follow `doctors_screen_test.dart` for the state table, then
  add the screen to the text-scaling matrix in `accessibility_test.dart`.
