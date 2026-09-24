# CareRoute Mobile

<p align="left">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47.5%20stable-02569B?logo=flutter">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart">
  <img alt="tests" src="https://img.shields.io/badge/tests-131%20passing-brightgreen">
  <img alt="analyze" src="https://img.shields.io/badge/flutter%20analyze-0%20issues-success">
</p>

**CareRoute** is a healthcare provider discovery app: browse providers, search
and filter by specialty and city, inspect full profiles with weekly
availability, save favorites, and request appointments — all with
production-grade error handling, accessibility and test coverage.

It was built as a **portfolio project for a Flutter developer role**: every
layer (networking, state, persistence, UI, tests, CI) is implemented the way a
production codebase would be, and the reasoning is documented in
[`docs/`](docs/).

| Area | Choices |
| --- | --- |
| State management | Riverpod 3 (AsyncNotifier / Notifier / FutureProvider) |
| Navigation | GoRouter with an auth-aware `redirect` |
| Networking | Dio 5 + interceptors, mapped to a typed error taxonomy |
| Models | Freezed + json_serializable DTOs → domain entities |
| Persistence | `flutter_secure_storage` (session), `shared_preferences` (favorites, theme) |
| Images | `cached_network_image` with downsampled decoding |
| Testing | 131 unit / repository / state / widget / integration tests |

## Screens

| Screen | Highlights |
| --- | --- |
| Splash → Login / Register | session restore, inline + live-region form errors, demo account |
| Discover | debounced search (350 ms), specialty chips, city picker, server-side pagination, pull-to-refresh, skeleton loading, empty/error/load-more retry states |
| Provider detail | full profile, weekly schedule, stats, favorites, appointment request sheet (day chips → slot chips → reason → submit) with server-side validation errors |
| Saved | persisted favorites, optimistic toggles |
| Appointments | upcoming/past sections, status badges, cancellation with confirmation |
| Profile | account info, light/dark theme, **API condition simulator** (offline / timeout / 500 / malformed / latency), sign out |

## The honest "mock API" story

The app talks to a **deterministic in-process REST API** through the *real*
Dio pipeline — request serialization, `AuthInterceptor` bearer tokens,
status codes, JSON decoding, timeouts and cancellation are all genuinely
exercised. The `MockBackendAdapter` implements Dio's `HttpClientAdapter`, so
swapping to a live Laravel/Node backend is a **one-line change** (replace the
adapter in `lib/presentation/providers/infrastructure_providers.dart`) — no
repository or UI code changes. See [`docs/API.md`](docs/API.md).

Try the **demo account** on the login screen (`Use demo account`), then open
**Profile → API condition simulator** to experience the offline, timeout,
server-error and malformed-response states end to end.

## Project layout

```
lib/
  core/        error taxonomy, Dio mapping, mock backend, storage seams,
               theme, validators, debouncer
  data/        DTOs (json_serializable), mappers, repository implementations
  domain/      Freezed entities + repository interfaces
  presentation/
    providers/ Riverpod controllers & infrastructure wiring
    routes/    GoRouter configuration (auth-aware redirect)
    screens/   splash, auth, doctors, favorites, appointments, profile, shell
    widgets/   doctor card, avatar, skeletons, empty/error views, form field
test/
  core/        debouncer, validators, error mapping, mock backend behavior
  data/        repository tests through the real Dio pipeline
  domain/      (covered via entity semantics in data tests)
  providers/   controller/state tests (pagination, debouncing, expiry…)
  widget/      screen + accessibility contract tests
  integration/ full golden-path flow (login → discover → favorite → book)
```

## Getting started

```bash
flutter pub get
flutter run           # pick an Android emulator / device / Chrome
```

Quality gates (all green at time of writing):

```bash
dart format --output=none --set-exit-if-changed .   # 97 files, 0 changed
flutter analyze                                    # no issues
flutter test                                       # 131 passed
```

CI runs the same three gates on every push and pull request
([`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml)).

## Documentation

| Document | Contents |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | layering, dependency rules, data flow diagrams |
| [docs/STATE_MANAGEMENT.md](docs/STATE_MANAGEMENT.md) | Riverpod patterns, provider inventory, retry policy |
| [docs/API.md](docs/API.md) | endpoints, payloads, error contract, mock backend design |
| [docs/TESTING.md](docs/TESTING.md) | test pyramid, 131-test inventory, how to extend |
| [docs/PERFORMANCE.md](docs/PERFORMANCE.md) | list virtualization, rebuild scoping, image memory |
| [docs/ACCESSIBILITY.md](docs/ACCESSIBILITY.md) | semantics, touch targets, text scaling — with test evidence |
| [docs/RELEASE.md](docs/RELEASE.md) | versioning, Android APK/AAB, signing, store flows |
| [docs/AI_WORKFLOW.md](docs/AI_WORKFLOW.md) | how AI assistance was used and verified |
| [docs/INTERVIEW_GUIDE.md](docs/INTERVIEW_GUIDE.md) | 48 repo-specific Q&A for interview prep |
| [docs/CV_EVIDENCE.md](docs/CV_EVIDENCE.md) | verified, evidence-backed CV bullets |

## Requirements

- Flutter stable (verified with 3.47.5 / Dart 3.13.4)
- Android: release APK (19.9 MB) and AAB (19.7 MB) built and verified on
  Linux — arm64 with debug signing (sandbox constraints documented in
  [docs/RELEASE.md](docs/RELEASE.md))
- iOS: **not verified** — requires macOS/Xcode (documented honestly in
  [docs/RELEASE.md](docs/RELEASE.md))

## License

Portfolio project — all code written for demonstration purposes.
