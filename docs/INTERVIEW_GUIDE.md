# CareRoute Interview Guide

Everything below is about **this repository** — you can open every file
mentioned and see the code working. Questions are grouped by topic; each
has a *simple answer* (say this first), a *deeper technical answer*
(impress with this), and the *files to review*.

Read [README.md](../README.md) first, then skim
[docs/ARCHITECTURE.md](ARCHITECTURE.md). Then this guide top to bottom.

---

## A. Project overview (4 questions)

### 1. What is CareRoute, in one sentence?

**Simple:** A Flutter app that helps patients discover healthcare
providers: search/filter by specialty and city, view profiles, save
favorites and request appointments.

**Deeper:** It's a portfolio project built to demonstrate production
discipline: a layered architecture (domain/data/presentation), Riverpod
state, an auth-aware router, a typed error taxonomy mapping every network
failure to user-safe messages, accessibility contracts enforced by
tests, and 131 automated tests including an end-to-end user flow. It runs
against a deterministic in-process REST backend wired into Dio's
`HttpClientAdapter`, so the entire HTTP pipeline is real and swappable.

**Files:** `README.md`, `PROJECT_SPEC.md`, `lib/main.dart`, `lib/app.dart`

### 2. What are the screens and the user flow?

**Simple:** Splash → Login/Register → four tabs: Discover (provider
list), Saved (favorites), Appointments (requests + cancel), Profile
(theme + API simulator + logout). Tapping a provider opens a detail
screen with an appointment-request bottom sheet.

**Deeper:** Navigation is a single `GoRouter` with a `StatefulShellRoute`
holding four `StatefulShellBranch`es — each tab keeps its own scroll
position and nav state via an `IndexedStack`. The detail route uses the
root navigator so it covers the tab bar. The `redirect` function decides
splash (session restoring), login (signed out) or home (signed in) on
every navigation.

**Files:** `lib/presentation/routes/app_router.dart`,
`lib/presentation/screens/shell/home_shell.dart`

### 3. Which packages does it use and why?

**Simple:** Riverpod (state), GoRouter (navigation), Dio (HTTP),
Freezed + json_serializable (immutable models/DTOs),
flutter_secure_storage (token), shared_preferences (favorites/theme),
cached_network_image (photos), intl (dates), mocktail (test doubles).

**Deeper:** Each choice is justified by a problem: Riverpod for
compile-safe DI + granular rebuild scoping without BuildContext; GoRouter
for declarative, testable routing with deep links; Dio because
interceptors/middleware are first-class (auth token injection, 401
detection); Freezed for `==`/`copyWith`/sealed classes without
hand-writing them; json_serializable keeps JSON decoding in generated
code (no hand-rolled `fromJson` bugs).

**Files:** `pubspec.yaml`

### 4. How big is the app and its test suite?

**Simple:** ~3,000 lines of Dart across 50+ source files; 131 tests
(unit, repository, state, widget, one integration flow); analyzer clean;
`dart format` clean; CI on GitHub Actions.

**Deeper:** The test pyramid is deliberately weighted toward the seams
where bugs actually appear: transport mapping (Dio errors → domain
exceptions), controller state transitions (pagination, debounce,
optimistic updates), and screen state tables (loading/empty/error/retry).
The single integration test boots the real `CareRouteApp` — real router,
real providers, real Dio — and drives the entire login → discover →
favorite → book path.

**Files:** `test/` (all), `.github/workflows/flutter_ci.yml`

---

## B. Dart & language (5 questions)

### 5. Where does the codebase use modern Dart features?

**Simple:** Sealed classes for errors, records for tuple returns,
pattern matching in `switch`, null-safety throughout, `late final`,
factory/abstract interface classes.

**Deeper:** `AppException` is a `sealed class` — the compiler guarantees
`DioExceptionMapper`'s switch handles every subtype, so adding a new
error type is a compile error until it's mapped. Dart 3 records appear in
`HomeShell._destinations` (named record fields `(:icon, :selectedIcon,
:label)` destructured in a loop). The mock database seeds with list-of-
records literals for specialties.

**Files:** `lib/core/errors/app_exception.dart`,
`lib/presentation/screens/shell/home_shell.dart`,
`lib/core/network/mock_backend/mock_database.dart` (line ~91)

### 6. How are nullable types handled at the boundaries?

**Simple:** API nullability stops at the DTO/mapper layer; the domain
uses explicit optionality (`String? phone`), and screens treat
`AsyncValue.value` as nullable-but-typed.

**Deeper:** DTOs mirror the API contract exactly (nullable where the API
can omit fields); mappers apply defaults/coercion so entities carry only
business-relevant optionality. A subtle bug this project fixed: a
`copyWith(forceStatus: null)` that couldn't clear the field because
`null` means "not provided" — solved with an `Object?` sentinel default
(`identical(forceStatus, _unset)`), a canonical Dart pattern for
nullable-copyWith semantics.

**Files:** `lib/core/network/mock_backend/backend_conditions.dart`
(`copyWith`), `lib/data/mappers/*`

### 7. What is `const` doing for performance here?

**Simple:** `const` widgets/objects are canonicalized — identical
instances are skipped during rebuilds and tree diffing.

**Deeper:** Static subtrees (skeletons, icons, spacing, empty views) are
`const`-constructed, so a parent rebuilding (e.g. the feed state
changing) doesn't re-run their `build`. The lint set doesn't force
`const` everywhere, but hot paths (list items) use it consistently;
`dart format`/analyze keep the codebase honest.

**Files:** `lib/presentation/widgets/skeleton_tile.dart`,
`lib/presentation/screens/doctors/doctors_screen.dart`

### 8. How does the codebase avoid leaking implementation details through exceptions?

**Simple:** One sealed hierarchy (`AppException`) with a `userMessage`
that's safe to render; raw errors are attached as `cause` for logging but
never displayed.

**Deeper:** Every repository wraps calls in a `_guard` that maps any
non-`AppException` through `DioExceptionMapper`; the mock backend's error
bodies (`{message, errors}`) flow through as `serverMessage` — the UI
prefers the API's wording when present. Widget code only ever sees
`AppException` (or nothing — `AsyncValue.error`).

**Files:** `lib/data/repositories/appointment_repository_impl.dart`
(`_guard`), `lib/core/network/dio_exception_mapper.dart`

### 9. Why `abstract interface class` / `abstract final class` markers?

**Simple:** They document intent and enforce rules: no implementation
inheritance for interfaces, no extension for utility classes.

**Deeper:** `AuthLocalDataSource` is an `abstract interface class`
(implement, don't extend — the secure-storage and in-memory versions are
unrelated implementations). `DioExceptionMapper` is `abstract final`
(a static-only namespace that shouldn't be instantiated or subclassed).
These markers make the architecture rules compiler-checked, not
convention-only.

**Files:** `lib/data/datasources/auth_local_data_source.dart`,
`lib/core/network/dio_exception_mapper.dart`

---

## C. Architecture (7 questions)

### 10. Describe the layering.

**Simple:** `domain/` (entities + repository interfaces) ← `data/`
(impls: DTOs, mappers, repositories) and `presentation/` (Riverpod +
widgets). `core/` holds cross-cutting infrastructure (network, errors,
storage, theme).

**Deeper:** Dependencies point *inward*: domain imports nothing from
data/presentation; data implements domain interfaces; presentation only
consumes domain types. The payoff is the swap seam — replacing the mock
backend with a Laravel API is one line in the composition root; replacing
secure storage with another vault touches one class. Widgets never import
Dio, DTOs, or JSON code.

**Files:** `docs/ARCHITECTURE.md`, `lib/domain/`, `lib/data/`,
`lib/presentation/`

### 11. Why repository interfaces in the domain layer (some would call that over-engineering)?

**Simple:** Repositories express *what the app can do* (search doctors,
request appointment); implementations express *how*. Tests and future
backends swap the "how".

**Deeper:** The interface lives in domain (not data) so the domain layer
is self-contained and the presentation depends only on contracts. It
also gave the test suite its shape: repository tests run the *real* Dio
pipeline against a deterministic backend, and state tests inject fresh
databases via Riverpod overrides — without a single mock of a repository.

**Files:** `lib/domain/repositories/*.dart`

### 12. Where is the composition root?

**Simple:** `presentation/providers/infrastructure_providers.dart` — it
builds the Dio, the repositories, and exposes them as `Provider`s.

**Deeper:** All wiring (Dio with timeouts + `AuthInterceptor` +
`MockBackendAdapter`, each repository constructor) happens in one file of
plain `Provider`s. `main()` adds the single platform override
(`SharedPreferences`) and the retry policy. This is the DI pattern:
nothing else constructs infrastructure, so nothing else needs changing
when infrastructure changes.

**Files:** `lib/presentation/providers/infrastructure_providers.dart`,
`lib/main.dart`

### 13. How does DTO → domain mapping work, and why bother?

**Simple:** DTOs match API JSON exactly; mappers convert them into
Freezed entities that the UI actually uses. One shape per audience.

**Deeper:** JSON contracts drift (snake_case, optional fields, default
values); the app's model shouldn't. `appointment_mapper.dart` and friends
are pure functions — trivially testable, no logic duplication. If the
backend renames a field, exactly one mapper line changes.

**Files:** `lib/data/dto/*`, `lib/data/mappers/*`

### 14. Why does a `SessionEvents` stream exist instead of the interceptor calling logout directly?

**Simple:** To break a dependency cycle: Dio → session controller →
repository → Dio would be impossible.

**Deeper:** The interceptor (deep in the network stack) detects "401 with
a token attached" and *notifies*; `SessionController` subscribes, clears
local state, and the router reacts. This inversion keeps the network
layer free of app-state knowledge — the same event pattern you'd use for
token *refresh* later.

**Files:** `lib/core/network/session_events.dart`,
`lib/core/network/auth_interceptor.dart` (`onError`),
`lib/presentation/providers/session_providers.dart` (subscription)

### 15. Why is business logic kept out of widgets?

**Simple:** Screens map state → UI and forward intents to controllers;
all decisions live in controllers/repositories where they're testable.

**Deeper:** Example: pagination logic (guard against double-fetch, stale
response detection via a request sequence number, load-more error state)
lives in `DoctorsController`. The screen just renders `DoctorsState` and
calls `loadNextPage()`. That's why 30+ controller tests cover the logic
without pumping a single widget.

**Files:** `lib/presentation/providers/doctors_providers.dart` vs
`lib/presentation/screens/doctors/doctors_screen.dart`

### 16. How would you add a "booking confirmation" feature end to end?

**Simple:** Entity + repository method + DTO/mapper + provider state +
screen — each in its layer, each with tests.

**Deeper:** Domain: extend `AppointmentRepository` (confirm semantics).
Data: endpoint in the mock database + DTO field + mapper. State: a
controller method updating `appointmentsProvider`. UI: a confirm action
on the appointment tile. Tests: repository test for the endpoint mapping,
controller test for the state transition, widget test for the tile
action. The layering *is* the implementation plan.

**Files:** `lib/domain/repositories/appointment_repository.dart` (pattern
to extend)

---

## D. State management (8 questions)

### 17. Why Riverpod over Bloc/BLoC/Provider/setState?

**Simple:** Compile-safe providers, granular rebuild control, first-class
async state, and providers work outside widgets (tests need no widget
tree).

**Deeper:** The clincher for tests: `ProviderContainer` runs controllers
in plain Dart tests. Features used: `AsyncNotifier` for feed/auth/favorites,
`Notifier` for filters, `FutureProvider.family` for per-doctor detail and
availability, a derived `Provider` for upcoming appointments. BLoC would
need ~3× the boilerplate for the same behavior; setState can't express
dependency graphs.

**Files:** `lib/presentation/providers/doctors_providers.dart`

### 18. What's the difference between Notifier and AsyncNotifier here?

**Simple:** `Notifier` = synchronous state (filters, theme);
`AsyncNotifier` = async state with loading/error/data (`AsyncValue`).

**Deeper:** `DoctorFiltersController` (Notifier) updates instantly —
it's pure UI state. `DoctorsController` (AsyncNotifier) fetches in
`build()`; Riverpod wraps it in `AsyncValue`, and mutation methods
(`loadNextPage`) update state while keeping it typed. The UI maps states
with `when(...)` + tuned `skipLoadingOnReload/Refresh` flags — the
loading semantics are a *design decision*, documented per screen.

**Files:** `lib/presentation/providers/doctors_providers.dart`,
`lib/presentation/providers/theme_mode_provider.dart`

### 19. How does the search debounce work?

**Simple:** Typing schedules a 350 ms timer; each keystroke resets it;
the query commits only after typing goes quiet.

**Deeper:** `Debouncer` is a pure class (unit-tested, no Flutter imports)
owned by `DoctorFiltersController`; `ref.onDispose` cancels the timer
when the provider dies. `clearSearch()` cancels and commits immediately —
the intent is unambiguous. Since `doctorsProvider`'s `build()` *watches*
the filters provider, the committed query automatically restarts the
feed — no manual wiring.

**Files:** `lib/core/utils/debouncer.dart`,
`lib/presentation/providers/doctors_providers.dart`,
`test/core/debouncer_test.dart`

### 20. How does pagination handle race conditions?

**Simple:** A request-sequence counter: every feed restart increments it;
a load-more response from an outdated sequence is dropped.

**Deeper:** Fast typing → filter change → `build()` restarts (seq 2)
while page 2 of the *old* query (seq 1) is still in flight. When it
lands, `seq != _requestSeq` → discard instead of appending stale doctors
to the new results. Plus `loadingMore` guards double-fires, and
load-more *errors* never destroy the list — they render a retry footer.

**Files:** `lib/presentation/providers/doctors_providers.dart`
(`_requestSeq`), `test/providers/doctors_controller_test.dart`

### 21. What is optimistic UI in this app and how is failure handled?

**Simple:** Toggling a favorite flips the heart instantly; if saving
fails, the state rolls back and a snack bar explains.

**Deeper:** `FavoritesController.toggle` computes the next set, sets it,
then persists; on error it restores the *previous* immutable set and
rethrows — the widget layer catches and surfaces it. Because each heart
watches `isFavoriteProvider(id)` (a family), the rollback also rebuilds
exactly the affected button.

**Files:** `lib/presentation/providers/favorites_providers.dart`,
`lib/presentation/widgets/favorite_button.dart`

### 22. How are rebuilds scoped in the list?

**Simple:** Each favorite button watches its own tiny provider; the list
watches the feed provider; the counter watches a derived value. Toggling
one heart rebuilds one button.

**Deeper:** `isFavoriteProvider = Provider.family<bool, String>` — Riverpod
invalidates only dependents of that family instance. The doctor cards'
`Semantics`+`InkWell` structure means the card content itself doesn't
watch anything (data is passed in via constructor) — a textbook
"make widgets leaf nodes" pattern.

**Files:** `lib/presentation/providers/favorites_providers.dart`,
`lib/presentation/widgets/doctor_card.dart`

### 23. Why did you disable Riverpod's automatic retry?

**Simple:** Repositories already classify errors; auto-retrying 401/422
requests is wrong, and the UI owns retry UX (buttons everywhere).

**Deeper:** Riverpod 3 retries failing providers with exponential
backoff by default. `main()` passes `retry: (_, _) => null` so a failed
`doctorsProvider` surfaces its error *immediately* — which both the
retry-button UX and the test suite (errors must be assertable on first
failure) depend on. The decision is documented where it's configured.

**Files:** `lib/main.dart` (`appRetryPolicy`),
`test/helpers/test_container.dart` (same policy)

### 24. How is theme state persisted?

**Simple:** A `Notifier<ThemeMode>` writes to SharedPreferences; the app
rebuilds with the new mode.

**Deeper:** The store is injected as a `KeyValueStore` seam — production
uses `SharedPreferencesKeyValueStore`, tests an in-memory map, so the
controller test verifies persistence without the plugin. Light/dark
themes are two `ThemeData` builds from one seed ColorScheme (Material 3).

**Files:** `lib/presentation/providers/theme_mode_provider.dart`,
`lib/core/storage/key_value_store.dart`, `lib/core/theme/app_theme.dart`

---

## E. Networking & the mock backend (7 questions)

### 25. How is Dio configured?

**Simple:** One Dio instance: base URL, 8 s connect/receive/send
timeouts, `Accept: application/json`, `AuthInterceptor`, and a custom
`HttpClientAdapter` for the mock backend.

**Deeper:** Timeouts on `BaseOptions` are the enforcement point for the
simulated-hang condition: the mock returns a response whose byte stream
never delivers, and Dio's *receiveTimeout* aborts it — the same code path
as a real stalled socket. The interceptor injects the bearer token via a
`tokenReader` closure (async, failure-tolerant) and reports 401s with
tokens as session-expiry events.

**Files:** `lib/presentation/providers/infrastructure_providers.dart`,
`lib/core/network/auth_interceptor.dart`

### 26. How does error mapping work?

**Simple:** One function turns any thrown thing into an `AppException`
subtype with a user-safe message; repositories guard every call with it.

**Deeper:** `DioExceptionMapper.map` unwraps Dio's "unknown" wrappers,
switches on error type (connection → `NoNetwork`, timeout variants →
`Timeout`, status codes → 401/403/404/422/5xx types, JSON parse failures →
`Parsing`), extracts the API's `message` as `serverMessage` when present.
Sealed-class exhaustiveness means new error types can't be silently
unhandled. 422 responses carry a field-error map that the appointment
sheet renders inline, exactly like client-side validation.

**Files:** `lib/core/network/dio_exception_mapper.dart`,
`test/core/dio_exception_mapper_test.dart`

### 27. What is the mock backend, and is it a "fake API"?

**Simple:** A deterministic in-process database served through Dio's
adapter interface — so the real HTTP pipeline runs; only the socket is
replaced.

**Deeper:** `MockBackendAdapter implements HttpClientAdapter` — the seam
Dio uses for *any* transport. Requests are serialized, headers set,
interceptors run, statuses honored, timeouts enforced, cancellation
supported. The `MockDatabase` seeds 72 providers deterministically,
validates registrations/logins/bookings (future dates, offered slots,
double-booking), issues self-describing tokens (`mt_<user>_<expiry>`)
that expire like JWTs, and lazily prunes sessions. Swapping to a real
server = deleting the adapter line. Calling it a "fake API" misses the
point: it's a *test double at the transport seam*, like WireMock but
in-process and deterministic.

**Files:** `lib/core/network/mock_backend/`,
`docs/API.md`

### 28. How does session expiry work end to end?

**Simple:** Any 401 (with a token attached) → event → session cleared →
router redirects to login with an expiry banner.

**Deeper:** Token format embeds expiry, so even pruned tokens are
rejected as expired, mirroring signed-JWT semantics. On boot,
`restoreSession()` calls `GET /auth/me` — boot failures (e.g. offline)
land on a splash *retry* state, not a silent login redirect. The login
screen listens for the expiry notice and shows it above the form.

**Files:** `lib/core/network/mock_backend/mock_database.dart`
(`_userForToken`, `_parseTokenExpiry`),
`lib/presentation/providers/session_providers.dart`,
`lib/presentation/screens/splash/splash_screen.dart`

### 29. How would you point the app at a Laravel backend?

**Simple:** Remove the adapter line in `dioProvider`, change `baseUrl`,
match the documented contract.

**Deeper:** The full contract (routes, payloads, error shapes, pagination
metadata, auth rules) is in `docs/API.md` including a Laravel
implementation checklist. Repositories, mappers, providers and most tests
are contract-based, not seed-based, so they remain valid. The
`BackendConditions` simulator is simply never provisioned in production.

**Files:** `docs/API.md`, `lib/presentation/providers/infrastructure_providers.dart`

### 30. Why does the availability sheet fetch per doctor with `family`?

**Simple:** Each doctor's calendar is its own provider keyed by id —
cached per profile, invalidated independently, parallel-fetchable.

**Deeper:** `availabilityProvider = FutureProvider.family<List<AvailabilityDay>,
String>` auto-disposes when the detail screen closes (default family
lifecycle), so memory doesn't grow with visits. Retrying from the sheet's
error view is `ref.invalidate(availabilityProvider(id))` — one line, no
controller code.

**Files:** `lib/presentation/providers/doctors_providers.dart`,
`lib/presentation/screens/doctors/appointment_request_sheet.dart`

### 31. How is request cancellation handled?

**Simple:** The mock adapter honors Dio's `cancelFuture` and resolves
with a cancellation error, like a real socket.

**Deeper:** `MockBackendAdapter.fetch` wires `cancelFuture` to a
completer that errors the pending response — so `CancelToken` semantics
work in tests (and the timeout-path stream handler also reacts to
cancellation). Few apps test this path; it's cheap here because the
adapter is the seam.

**Files:** `lib/core/network/mock_backend/mock_backend_adapter.dart`

---

## F. UI, responsive & accessibility (8 questions)

### 32. How does the discovery list stay smooth with images?

**Simple:** Lazy `ListView.builder` (only visible cards exist), cached
images downsampled to 2× display size, `const` subtrees.

**Deeper:** Preloading triggers 320 px before the list end via
`NotificationListener<ScrollNotification>` (no controller bookkeeping).
`DoctorAvatar` passes `memCacheWidth` so a 64 dp avatar decodes ~128 px —
memory stays flat regardless of source resolution; placeholder and error
fall back to initials so dead URLs never render broken boxes.

**Files:** `lib/presentation/screens/doctors/doctors_screen.dart`,
`lib/presentation/widgets/doctor_avatar.dart`

### 33. How does the app handle narrow screens and large text?

**Simple:** Flexible rows wrap instead of overflow; text ellipsizes when
it can't; tests pump both screens at 1.0/1.3/2.0× text scale and assert
zero overflow.

**Deeper:** The metadata lines use `Wrap` with intrinsic `Row(
mainAxisSize.min)` children holding `Flexible(Text(ellipsis))` — content
reflows to a second line rather than clipping. This exact pattern was
applied after a real 65 px overflow appeared in the detail screen next to
the avatar. The text-scale matrix in `accessibility_test.dart` fails CI
on regression.

**Files:** `lib/presentation/widgets/doctor_card.dart`,
`lib/presentation/screens/doctors/doctor_detail_screen.dart` (`_NameBlock`),
`test/widget/accessibility_test.dart`

### 34. What accessibility semantics does the app expose?

**Simple:** Every meaningful control has a label: cards announce
"name, specialty, rating, city", chips announce "Filter by X, N
providers", skeletons announce "Loading providers".

**Deeper:** The doctor card merges its content into ONE semantics node
while keeping the heart toggle separate — screen-reader users can
favorite without entering the card. Decorative skeletons are
`ExcludeSemantics`d and the container is a single labeled node (verified
by walking the `SemanticsNode` tree in a test). Error banners are
`liveRegion`s so they're announced on appearance.

**Files:** `lib/presentation/widgets/doctor_card.dart` (`Semantics`),
`lib/presentation/widgets/skeleton_tile.dart`,
`test/widget/accessibility_test.dart`

### 35. Why 48 px touch targets, and how is that guaranteed?

**Simple:** Minimum comfortable touch size; a test walks every
`IconButton` on screen and asserts each render box ≥ 48×48 logical px.

**Deeper:** Material's `IconButton` defaults guarantee it, but the test
exists so custom controls (the heart button wrapping logic, any future
icon button) can't silently regress. Chips are 44+ px tall, primary
buttons 52 px.

**Files:** `test/widget/accessibility_test.dart` ("touch targets" group)

### 36. How does the appointment sheet make errors accessible?

**Simple:** Server field errors render inline under fields; form-level
errors render in a live-region banner.

**Deeper:** The 422 contract carries `errors: {field: [messages]}`; the
sheet stores them in `_fieldErrors` and renders them exactly where
Material form validation would — one error UX, two sources. `_formError`
(sessions, transport) uses `Semantics(liveRegion: true)`.

**Files:** `lib/presentation/screens/doctors/appointment_request_sheet.dart`,
`docs/API.md` (error contract)

### 37. How does the auth-aware redirect work?

**Simple:** One `redirect` function maps (session state, current route)
→ destination: restoring → splash, signed-out → login, signed-in on auth
route → home.

**Deeper:** The router *provider* watches `sessionProvider`, so login/
logout/expiry rebuild the router and re-evaluate the redirect — a
declarative state machine instead of imperative `pushReplacement` calls
scattered across callbacks. Deep links stay intact for non-auth routes.

**Files:** `lib/presentation/routes/app_router.dart`

### 38. How was the "stale render offset" test bug found and fixed?

**Simple:** `ensureVisible()` scrolls but render objects keep old
offsets until a frame is pumped — tap coordinates were read stale (the
tap landed off-screen).

**Deeper:** Symptom: submit tap "worked" but nothing happened; prints
showed the button center at y=968 on an 891 px screen. Fix: pump after
`ensureVisible` before tapping. It's documented in the test because it's
a framework gotcha every Flutter tester hits eventually.

**Files:** `test/integration/discovery_flow_test.dart` (comment on
`ensureVisible`)

### 39. Why Wrap instead of Row for the filter/city bar?

**Simple:** `Wrap` lets content flow to a second line; `Row` with
intrinsic children overflows when space runs out.

**Deeper:** The city label uses `Flexible(Text(ellipsis))` inside the
picker row so "Montreal" ellipsizes rather than pushing the result count
off-screen; the doctor card's fee/next-visit row wraps on narrow phones.
`WrapCrossAlignment.center` keeps wrapped lines aligned.

**Files:** `lib/presentation/screens/doctors/doctors_screen.dart`
(`_CityPicker`), `lib/presentation/widgets/doctor_card.dart`

---

## G. Testing (6 questions)

### 40. Describe the test suite.

**Simple:** 131 tests: pure unit (debouncer, validators, mappers,
mock-backend behavior), repository tests through real Dio, controller
tests, screen/widget tests, one integration flow.

**Deeper:** `createTestContainer()` gives every test an isolated
`ProviderContainer` with fresh database + in-memory storage + fixed
conditions. Repository tests construct their own Dio via
`createTestDio` when they need custom timeouts. The integration test
overrides only the platform storage seams — everything else is the real
app object.

**Files:** `test/helpers/test_container.dart`, `docs/TESTING.md`

### 41. How do widget tests avoid fake-passing?

**Simple:** Assertions target behavior (state transitions, presence of
retry UI, recovery after healing the backend), and every state of the
table gets a test.

**Deeper:** The retry test *actually mutates* the backend conditions
mid-test, taps "Try again", and asserts data returns. The search test
respects the real debounce window (pumps 350 ms+). The chips test scrolls
the lazy horizontal list into view first. Each test documents the timing
quirk it depends on.

**Files:** `test/widget/doctors_screen_test.dart`

### 42. What did the Dio timer discovery teach you about widget tests?

**Simple:** Dio delivers responses via zone timers (its receive-timeout
watchdog), so `pump()` alone (microtasks) never completes a request —
tests must advance fake time.

**Deeper:** The `settle()` helper in the integration test pumps plain +
120 ms + plain. Without it, login appeared to "hang" in tests. Also:
requests still in flight at test end leave pending timers → binding
assertion failures — settle after *every* intent that triggers requests.

**Files:** `test/integration/discovery_flow_test.dart` (`settle` helper
+ timing note)

### 43. How are controllers tested without widgets?

**Simple:** `ProviderContainer` from the test helper — read the
controller, call methods, assert state transitions.

**Deeper:** Example: `doctors_controller_test.dart` drives
`loadNextPage` twice, forces a filter change mid-flight, and asserts the
stale response was dropped — pure Dart, no pumping, fast. Same pattern
covers optimistic favorites rollback and session expiry propagation.

**Files:** `test/providers/doctors_controller_test.dart`,
`test/providers/favorites_controller_test.dart`

### 44. How does the accessibility test walk the semantics tree?

**Simple:** Enable semantics, find the root `SemanticsNode` through the
render views' pipeline owner, and collect every label recursively.

**Deeper:** `tester.ensureSemantics()` activates semantics; the test
reaches the owner via `tester.binding.renderViews.first.owner` (the
non-deprecated path) and asserts the label list equals exactly
`['Loading providers']` — proving the merged announcement *and* the
`ExcludeSemantics`d tiles in one check.

**Files:** `test/widget/accessibility_test.dart`

### 45. What's the value of the single integration test?

**Simple:** It proves the pieces compose: router + providers + Dio +
backend + sheets + optimistic state, end to end.

**Deeper:** Unit tests can all pass while the wiring is broken (wrong
provider scoped, route not registered, sheet not opening). The golden
path — login → browse → detail → favorite → book → verify state — fails
if any seam breaks. It also caught two real bugs during development (the
overflow and the stale-offset tap), paying for itself immediately.

**Files:** `test/integration/discovery_flow_test.dart`

---

## H. CI & release (3 questions)

### 46. What does CI run?

**Simple:** On every push/PR: `flutter pub get`, `dart format
--set-exit-if-changed`, `flutter analyze`, `flutter test`.

**Deeper:** Format-as-gate keeps diffs reviewable; analyze-as-gate
enforces the lint discipline (zero suppressions in this repo); test-as-
gate runs all 131. The workflow uses the standard `subosito/flutter-action`
with the stable channel and Java 17 — same toolchain major as local.

**Files:** `.github/workflows/flutter_ci.yml`

### 47. What were the real build challenges on Linux, and how were they solved?

**Simple:** Memory (Gradle wanted 8 GB on a 4 GB box → tuned to 2 GB),
disk (NDK + multi-ABI artifacts → arm64-only build), missing JDK (only a
JRE installed → portable Temurin 17).

**Deeper:** All three are *environment* problems, not code problems —
solved with committed config (`gradle.properties` tuning) and documented
workarounds (RELEASE.md). The `jni` transitive package requires a real
NDK (it compiles CMake), so the NDK was genuinely installed and used.
The builds succeeded: 19.9 MB APK, 19.7 MB AAB, debug-signed, arm64.

**Files:** `android/gradle.properties`, `docs/RELEASE.md`

### 48. Why is iOS marked "not verified"?

**Simple:** iOS builds require macOS/Xcode; this machine is Linux. No
claim is made without a build.

**Deeper:** The honest-release posture runs through the whole repo:
debug signing is labeled, arm64-only is labeled, TalkBack-on-hardware is
labeled as untested in ACCESSIBILITY.md. For a portfolio aimed at a
company that values integrity, documented limitations *are* the signal.

**Files:** `docs/RELEASE.md` (iOS section), `docs/ACCESSIBILITY.md`
(known limitations)

---

## Rapid-fire: questions you should be able to answer cold

- Riverpod provider types used and where (Q17–Q18).
- The four async-value states and how each screen maps them (Q24,
  STATE_MANAGEMENT.md table).
- Sealed classes vs enums-with-data (Q5).
- Why repositories return domain entities, not DTOs (Q13).
- The debounce window length and why (Q19: 350 ms).
- Page size and pre-fetch trigger distance (Q32: 20/page, 320 px).
- The token format and its expiry semantics (Q28).
- The error contract shape (Q26: `{message, errors?}`).
- How many tests and the pyramid split (Q4: 131).
- The three gates and their results (Q46).

---

*Prepared as part of the CareRoute portfolio. Every file reference above
exists in this repository; every claim is backed by a command run
documented in [AI_WORKFLOW.md](AI_WORKFLOW.md).*
