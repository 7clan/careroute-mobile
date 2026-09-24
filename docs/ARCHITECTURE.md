# Architecture

CareRoute uses a **layered architecture** with strict dependency direction:
UI → state → domain ← data. The domain layer defines *what* the app does;
data and presentation define *how*.

```
┌───────────────────────────────────────────────────────────────┐
│ presentation/                                                 │
│   screens (Material 3 widgets)                                │
│   widgets  (reusable UI)                                      │
│   providers (Riverpod state + DI wiring)                      │
│   routes   (GoRouter, auth-aware redirect)                    │
└──────────────┬────────────────────────────────────────────────┘
               │ watches / calls (never reaches Dio directly)
┌──────────────▼───────────────┐   ┌─────────────────────────────┐
│ domain/                      │◄──│ data/                       │
│  entities   (Freezed)        │   │  dto          (json_        │
│  repositories (interfaces)   │   │               serializable) │
└──────────────────────────────┘   │  mappers       dto→entity   │
                                   │  repositories  impls        │
                                   │  datasources   local        │
                                   └───────┬─────────────────────┘
                                           │ Dio + interceptors
                                   ┌───────▼─────────────────────┐
                                   │ core/network                 │
                                   │  MockBackendAdapter          │
                                   │  (HttpClientAdapter)         │
                                   │  MockDatabase (deterministic)│
                                   └─────────────────────────────┘
```

## The dependency rule

- `domain/` imports **nothing** from `data/` or `presentation/`. Entities and
  repository interfaces are pure Dart (plus Freezed annotations).
- `data/` implements the domain interfaces. It knows Dio, DTOs and mappers —
  nothing about widgets or Riverpod.
- `presentation/` watches Riverpod providers and renders. Screens never
  import Dio, DTOs or JSON — only domain entities.

Consequence: the repository seam is the only place transport details exist.
Swapping the mock backend for a Laravel API (or adding a caching layer)
touches `infrastructure_providers.dart` and the `data/` layer only.

## Layer contents

### `core/` — cross-cutting infrastructure

| File | Role |
| --- | --- |
| `errors/app_exception.dart` | sealed error taxonomy (`NoNetwork`, `Timeout`, `Unauthorized`, `Forbidden`, `NotFound`, `Validation`, `Server`, `Parsing`, …) with user-safe `userMessage`s |
| `network/dio_exception_mapper.dart` | the *only* place Dio/HTTP errors become `AppException`s |
| `network/auth_interceptor.dart` | bearer-token injection + 401 session-expiry events |
| `network/session_events.dart` | breaks the would-be cycle Dio → session controller → repository → Dio |
| `network/mock_backend/*` | deterministic in-process REST API (see [API.md](API.md)) |
| `storage/key_value_store.dart` | `SharedPreferences` / in-memory seam |
| `theme/app_theme.dart` | Material 3 light + dark themes |
| `utils/validators.dart`, `utils/debouncer.dart` | pure, trivially testable |

### `domain/` — entities + contracts

Freezed models (`Doctor`, `DoctorPage`, `Specialty`, `AvailabilityDay`,
`Appointment`, `AuthSession`, `AppUser`, `DoctorQuery`) and abstract
repository interfaces (`DoctorRepository`, `AuthRepository`,
`FavoritesRepository`, `AppointmentRepository`).

### `data/` — implementations

- **DTOs** (`data/dto`) — json_serializable classes shaped exactly like the
  API payloads. Snake/camel mismatches, nullability and defaults live here.
- **Mappers** (`data/mappers`) — pure `Dto.toDomain()` conversions. This is
  where API shapes end and app shapes begin.
- **Repositories** (`data/repositories`) — orchestrate Dio calls + local
  storage behind domain interfaces; wrap every call so transport errors are
  always translated (`_guard`).
- **Local data source** (`data/datasources`) — `flutter_secure_storage`
  session persistence with an in-memory test double.

### `presentation/` — state + UI

- **providers/** — Riverpod controllers (see [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md)).
  `infrastructure_providers.dart` is the composition root: it builds the Dio
  instance and every repository.
- **routes/** — one GoRouter, rebuilt on session change; the `redirect`
  encodes the splash/login/home decision table.
- **screens/** — one folder per feature; screens stay "dumb": they map
  provider state to widgets and forward user intent to controllers.
- **widgets/** — shared building blocks (doctor card, avatar, skeletons,
  empty/error views, accessible form field).

## Key data flows

### Provider discovery (the interesting one)

```
DoctorsScreen ──watch──► doctorsProvider (AsyncNotifier<DoctorsState>)
                              │ build(): watch doctorFiltersProvider
                              │          → repository.fetchDoctors(query)
                              │ loadNextPage(): guarded by request sequence
                              │ refresh(): invalidateSelf
DoctorFiltersController ──────┤ search debounced 350 ms (core/utils/debouncer)
                              │ specialty/city setters reset to page 1
repository (DoctorRepositoryImpl)
    │ Dio GET /doctors?search=…&specialtyId=…&city=…&page=N
    ▼
MockBackendAdapter → MockDatabase (deterministic seed, 72 providers)
    │ 200 JSON │ 500 │ timeout stream │ malformed
    ▼
DoctorPageDto → mapper → DoctorPage (domain) → DoctorsState → UI
```

Failure at any hop becomes an `AppException`, which the UI renders through
`AppErrorView` (full-screen) or a retry footer (load-more), never a raw
stack trace.

### Authentication & session lifecycle

```
main() → SharedPreferences → ProviderScope(retry: null) → CareRouteApp
login()  → AuthRepositoryImpl → POST /auth/login → save session (secure storage)
App boot → SessionController.build() → restoreSession()
AuthInterceptor (401 + token) → SessionEvents.sessionExpired
          → SessionController (drops session, shows notice)
          → router rebuilds → redirect → /login
```

`SessionEvents` exists purely to break the dependency cycle: the
interceptor (deep inside Dio) cannot depend on the session controller
(which depends on repositories, which depend on Dio). A broadcast
stream decouples them.

### Favorites (optimistic, persisted)

```
DoctorCard/FavoriteButton → isFavoriteProvider(id)  (family = scoped rebuilds)
toggle(id) → optimistic state update → SharedPreferences write
           └─ fails → rollback + rethrow → snack bar
FavoritesScreen → favoriteDoctorsProvider → fetchDoctorsByIds
```

## Why not more abstraction?

No use-cases layer, no `Result<T>` type, no interfaces for every mapper.
The layering above already gives testability (repository tests run the real
Dio pipeline against the deterministic backend) and swappability (the
adapter seam). Extra layers would add ceremony without changing any
behavior — the codebase stays readable for a junior teammate, which is
part of the project's stated goal.
