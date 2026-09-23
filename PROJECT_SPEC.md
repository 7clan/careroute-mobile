# CareRoute Mobile — Implementation Specification

## Goal

Build a production-style Flutter application that demonstrates the exact capabilities expected from a junior Flutter developer: Dart, responsive interfaces, accessibility, REST API integration, state management, robust error handling, maintainable architecture, automated testing, performance awareness, Git/CI, and Android/iOS release readiness.

## Product

CareRoute helps users discover healthcare providers, inspect physician profiles, filter/search by specialty and location, save favorites, and request appointments.

This is a provider-discovery application, not a diagnostic tool.

## Required stack

- Flutter stable
- Dart stable
- Riverpod
- Dio
- GoRouter
- Freezed / json_serializable where useful
- flutter_secure_storage for auth tokens
- local persistence/cache where appropriate

Prefer a Laravel REST backend if practical. If not, isolate networking behind repository/data-source interfaces so a real backend can replace a mock API cleanly.

## Architecture

Use a layered structure such as:

lib/
- core/
- data/
- domain/
- presentation/

Separate:
- UI
- state
- business/domain logic
- repositories
- remote/local data sources
- models/DTOs

Avoid business logic inside large widgets.

## Core features

### Authentication
- Register
- Login
- Logout
- Form validation
- Secure token handling
- Expired-session handling

### Provider discovery
- Doctor list
- Doctor detail/profile
- Specialty browsing
- Search
- Filters
- Pagination
- Location metadata
- Availability metadata

### User features
- Favorites
- Appointment request flow
- Profile/account basics

## Application states

Every major screen should handle:
- initial
- loading
- success
- empty
- error
- retry

## Error handling

Handle:
- no connection
- timeout
- 4xx/5xx
- malformed JSON
- expired auth
- empty API responses

Do not surface raw exceptions to users.

## Responsive UI

Test multiple phone sizes and text scales.

Avoid brittle fixed-size layouts.

## Accessibility

Include:
- semantic labels
- accessible touch targets
- text scaling
- meaningful focus behavior
- readable contrast
- accessible form errors

## Performance

Demonstrate:
- const widgets where appropriate
- ListView.builder or slivers for lists
- debounced search
- pagination
- image caching
- avoiding unnecessary rebuilds

Document the reasoning.

## Testing

Include meaningful:
- unit tests
- repository/service tests
- Riverpod/state tests
- widget tests
- at least one integration-style user flow if practical

## CI

GitHub Actions should run:
- dart format --output=none --set-exit-if-changed .
- flutter analyze
- flutter test

## Release readiness

Create docs/RELEASE.md covering:
- versioning
- Android APK/AAB
- signing concepts
- Google Play flow
- iOS archive/signing concepts
- App Store flow

If the environment permits, verify:
- flutter build apk --release
- flutter build appbundle

Do not claim store publication unless it actually happens.

## Documentation

Create:
- docs/ARCHITECTURE.md
- docs/STATE_MANAGEMENT.md
- docs/API.md
- docs/TESTING.md
- docs/PERFORMANCE.md
- docs/ACCESSIBILITY.md
- docs/RELEASE.md
- docs/AI_WORKFLOW.md
- docs/INTERVIEW_GUIDE.md

INTERVIEW_GUIDE.md must explain the project in simple language and include likely technical interview questions and answers.

## Verification before completion

Run and report:
1. dart format .
2. flutter analyze
3. flutter test
4. Android release build if possible
5. Git status
6. secret scan/manual secret check

Do not report success unless the commands actually succeed.
