# CV Evidence

Every bullet below is **verifiable in this repository** — with the exact
files, tests or commands that prove it. Nothing here is aspirational.
Use these as ready-made CV/interview claims (adjust wording to your CV
style, keep the evidence links for interviews).

## Suggested CV bullets

### Flutter / mobile

> Built **CareRoute**, a production-style Flutter healthcare provider
> discovery app (Riverpod 3, GoRouter, Dio, Material 3) with a layered
> domain/data/presentation architecture.

Evidence: the whole repo; start at `lib/main.dart`,
`docs/ARCHITECTURE.md`.

> Implemented a typed error taxonomy mapping every network failure
> (offline, timeout, 4xx/5xx, malformed JSON, session expiry) into
> user-safe messages via a sealed class hierarchy — no raw exceptions
> reach the UI.

Evidence: `lib/core/errors/app_exception.dart`,
`lib/core/network/dio_exception_mapper.dart`,
`test/core/dio_exception_mapper_test.dart`,
`test/data/*_repository_test.dart`.

> Delivered accessible UI: semantic labels on every control, ≥48 px touch
> targets, live-region error announcements, and layout verified at 1.0×/
> 1.3×/2.0× text scale by automated widget tests.

Evidence: `test/widget/accessibility_test.dart` (9 tests),
`docs/ACCESSIBILITY.md`, `lib/presentation/widgets/doctor_card.dart`.

> Wrote **131 automated tests** (unit, repository, state, widget and an
> end-to-end integration flow) running in CI, all passing.

Evidence: `flutter test` → `00:21 +131: All tests passed!`;
`docs/TESTING.md`; `.github/workflows/flutter_ci.yml`.

> Solved real concurrency bugs in list pagination with a request-sequence
> guard against stale responses, plus debounced search, optimistic
> favorites with rollback, and scoped rebuilds via `Provider.family`.

Evidence: `lib/presentation/providers/doctors_providers.dart`
(`_requestSeq`), `lib/core/utils/debouncer.dart`,
`lib/presentation/providers/favorites_providers.dart`,
`test/providers/doctors_controller_test.dart`.

> Designed a swappable API layer: a deterministic in-process REST
> backend implementing Dio's `HttpClientAdapter` — the full HTTP
> pipeline (interceptors, status codes, timeouts, cancellation) is real;
> switching to a production backend is a one-line change.

Evidence: `lib/core/network/mock_backend/`, `docs/API.md`,
`lib/presentation/providers/infrastructure_providers.dart` (`dioProvider`).

### Performance

> Applied measurable list performance: lazy `ListView.builder` with
> pre-fetch pagination, downsampled image decoding (`memCacheWidth`),
> `const` subtrees, and per-item rebuild scoping.

Evidence: `lib/presentation/screens/doctors/doctors_screen.dart`,
`lib/presentation/widgets/doctor_avatar.dart`,
`docs/PERFORMANCE.md`.

### DevOps / release

> Configured GitHub Actions CI enforcing `dart format
> --set-exit-if-changed`, `flutter analyze` and `flutter test` on every
> push/PR.

Evidence: `.github/workflows/flutter_ci.yml` (format/analyze/test gates),
local results captured in `docs/AI_WORKFLOW.md`.

> Produced signed Android release artifacts (19.9 MB APK, 19.7 MB AAB) on
> a constrained Linux environment, tuning Gradle memory and resolving
> JDK/SDK/NDK toolchain issues; documented iOS as unverified (no macOS)
> rather than claiming it.

Evidence: `docs/RELEASE.md` (build commands, sizes, honest qualifiers),
`android/gradle.properties`.

### Engineering practices

> Authored deep engineering documentation — architecture, state
> management, API contract, testing, performance, accessibility, release,
> and a 48-question interview guide — where every claim links to source
> files or command output.

Evidence: `docs/` (10 documents).

> Disclosed AI-assisted development with a verification-first workflow:
> every change gated by format/analyze/test runs, zero lint
> suppressions, and root-cause fixes (including a nullable-`copyWith`
> bug and a narrow-screen overflow) captured in the docs.

Evidence: `docs/AI_WORKFLOW.md` (including the "what was NOT done"
section).

## Verified facts table (for interview prep)

| Claim | How to verify in 2 minutes |
| --- | --- |
| 131 tests pass | `flutter test` → "All tests passed!" (count in summary line) |
| Analyzer clean | `flutter analyze` → "No issues found!" |
| Format clean | `dart format --output=none --set-exit-if-changed .` → exit 0 |
| APK builds | `flutter build apk --release --target-platform android-arm64` → 19.9 MB |
| AAB builds | `flutter build appbundle --release --target-platform android-arm64` → 19.7 MB |
| No secrets committed | `git log -p` review; repo contains no tokens/keys |
| iOS unverified | `docs/RELEASE.md` states it explicitly |
| CI exists | `.github/workflows/flutter_ci.yml`; runs on push/PR |

## Interview one-liners (backed by this repo)

- "I can show you the exact test that enforces 48-pixel touch targets."
- "Ask me why Riverpod's auto-retry is disabled — there's a comment in
  `main.dart` and a doc section about it."
- "The pagination race condition? `DoctorsController._requestSeq` — and
  there's a controller test that reproduces it."
- "I disabled nothing in the analyzer and suppressed zero lints."
