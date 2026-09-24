# State Management

Riverpod 3 (with `flutter_riverpod`) is the single state solution. This
document explains every pattern used, where it lives, and why.

## The three provider kinds used

| Kind | Used for | Examples |
| --- | --- | --- |
| `NotifierProvider` | synchronous, mutable state | `doctorFiltersProvider`, `backendConditionsProvider`, `themeModeProvider`, `authNoticeProvider` |
| `AsyncNotifierProvider` | async state with mutation methods | `doctorsProvider`, `sessionProvider`, `favoritesProvider`, `appointmentsProvider` |
| `FutureProvider` / `Provider.family` | read-derived data, per-parameter data | `specialtiesProvider`, `citiesProvider`, `doctorDetailProvider`, `availabilityProvider`, `isFavoriteProvider` |

## Provider inventory

| Provider | Type | Purpose |
| --- | --- | --- |
| `sessionProvider` | `AsyncNotifier<AuthSession?>` | auth state; `null` = signed out |
| `authNoticeProvider` | `Notifier<String?>` | one-shot "session expired" banner |
| `doctorFiltersProvider` | `Notifier<DoctorQuery>` | search / specialty / city / page |
| `doctorsProvider` | `AsyncNotifier<DoctorsState>` | discovery feed: pages + retry state |
| `specialtiesProvider` | `FutureProvider<List<Specialty>>` | chip row data |
| `citiesProvider` | `FutureProvider<List<String>>` | city picker data |
| `doctorDetailProvider` | `FutureProvider.family<Doctor, String>` | profile by id |
| `availabilityProvider` | `FutureProvider.family<List<AvailabilityDay>, String>` | bookable calendar |
| `favoritesProvider` | `AsyncNotifier<Set<String>>` | persisted favorite ids |
| `isFavoriteProvider` | `Provider.family<bool, String>` | per-card favorite flag |
| `favoriteDoctorsProvider` | `FutureProvider<List<Doctor>>` | favorites screen data |
| `appointmentsProvider` | `AsyncNotifier<List<Appointment>>` | requests + mutations |
| `upcomingAppointmentsProvider` | `Provider<List<Appointment>>` | derived "upcoming" section |
| `themeModeProvider` | `Notifier<ThemeMode>` | persisted light/dark choice |
| `dioProvider` + repositories | `Provider` | composition root / DI |

## Pattern 1 — controllers own business logic, screens stay dumb

`DoctorsController` (in `doctors_providers.dart`) is the canonical example:

- `build()` watches `doctorFiltersProvider` — any filter change restarts the
  feed automatically (Riverpod dependency graph, no manual wiring).
- `loadNextPage()` guards against double-fetches (`loadingMore`) and
  **stale responses** via `_requestSeq`: if filters changed while a page was
  in flight, the response is dropped instead of corrupting the new result.
- `refresh()` (pull-to-refresh) uses `ref.invalidateSelf()` and awaits the
  new future so `RefreshIndicator` spins until data lands.

Screens call `ref.read(controller.notifier).method()` for intent and
`ref.watch(provider)` for rendering. No `setState` for app state anywhere
(only the appointment sheet's local form fields use it, which is correct —
they're ephemeral UI state).

## Pattern 2 — derived state instead of duplicated state

`upcomingAppointmentsProvider` *derives* the upcoming list from
`appointmentsProvider` — there is no second list to keep in sync.
`_ResultCount` similarly watches `doctorsProvider` for the "72 found" label.

## Pattern 3 — rebuild scoping with `Provider.family`

Every doctor card's heart button watches `isFavoriteProvider(doctor.id)` —
a family of tiny providers. Toggling one favorite rebuilds exactly one
button, not the list. (See [PERFORMANCE.md](PERFORMANCE.md).)

## Pattern 4 — debounced search

`DoctorFiltersController.updateSearch()` routes every keystroke through a
350 ms `Debouncer` (pure Dart, unit-tested). The provider state (and
therefore the network request) only commits after typing goes quiet.
`clearSearch()` cancels the pending timer and commits immediately — the
user's intent is unambiguous.

## Pattern 5 — optimistic updates with rollback

`FavoritesController.toggle()`:

1. mutate state immediately (UI flips the heart),
2. persist via the repository,
3. on failure restore the previous set and rethrow — the caller shows a
   snack bar.

The user never waits on storage I/O; correctness is preserved.

## Error handling & retry policy

Two deliberate decisions, both documented in code:

1. **Riverpod's built-in retry is disabled** (`lib/main.dart`:
   `retry: appRetryPolicy` returns `null`). Repositories already classify
   errors; auto-retrying a 401/422 is wrong, and the UI owns retry
   semantics: full-screen error views and load-more footers both ship a
   retry button. Tests rely on errors surfacing immediately.
2. **Errors surface as typed `AppException`s** — `AsyncValue.error` carries
   them to `AsyncValue.when(error:)`, which renders `error.userMessage`
   (never a stack trace). The splash screen additionally distinguishes
   "boot failed" (retry) from "signed out" (login).

`skipLoadingOnReload/skipLoadingOnRefresh` are tuned per screen:
discovery shows skeletons when the *query* changes (the user must see a new
search started) but keeps stale data during pull-to-refresh (standard
mobile UX).

## Provider scope & overrides

`main()` creates one root `ProviderScope` with a single override
(`sharedPreferencesProvider`) because plugin initialization is async. Tests
create isolated `ProviderContainer`s (see
`test/helpers/test_container.dart`) overriding: the database, key-value
store, auth storage and backend conditions — every test gets a fresh
deterministic world, no shared mutable state.

## AsyncValue → UI mapping (the state table)

Every list screen implements the same decision table:

| `AsyncValue` state | Discovery | Favorites / Appointments |
| --- | --- | --- |
| loading (initial / new query) | `DoctorListSkeleton` | skeleton (count: 3) |
| loading (refresh) | keep data, spinner from `RefreshIndicator` | same |
| data + empty | `AppEmptyView` (+ "Clear filters" / CTA) | `AppEmptyView` |
| data | `ListView.builder` + load-more footer | sections / tiles |
| error (initial) | `AppErrorView` + retry | `AppErrorView` + retry |
| error (load-more only) | footer message + retry, list stays visible | — |
