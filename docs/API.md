# API

CareRoute consumes a REST API described by this contract. The default
implementation is a **deterministic in-process backend** wired as a Dio
`HttpClientAdapter`; a Laravel/Node service implementing the same contract
can replace it with a one-line change (see *Swapping in a real backend*).

## Design goals

1. The app must exercise the **real** HTTP pipeline — serialization,
   interceptors, status codes, timeouts, cancellation — not a fake service
   class returning canned futures.
2. Behavior must be **deterministic** for tests and for demos (same seed →
   same responses).
3. Failure modes (offline, timeout, 500, malformed JSON, 401 expiry) must
   be reproducible on demand — the Profile tab ships an *API condition
   simulator* for exactly this.

## Endpoints

Base URL (mock): `https://api.careroute.local/v1`. Auth via
`Authorization: Bearer <token>`.

| Method & path | Auth | Purpose |
| --- | --- | --- |
| `POST /auth/register` | – | create account (`name, email, password, passwordConfirmation`) |
| `POST /auth/login` | – | sign in (`email, password`) → `{token, expiresAt, user}` |
| `POST /auth/logout` | ✓ | revoke token |
| `GET /auth/me` | ✓ | verify stored token → session restore |
| `GET /specialties` | – | `[{id, name, doctorCount}]` |
| `GET /meta/cities` | – | `[{items: [String]}]` |
| `GET /doctors` | – | paginated search: `?search&specialtyId&city&page&limit` |
| `GET /doctors/{id}` | – | full profile |
| `GET /doctors/{id}/availability?days=21` | – | `[{date, slots: ["09:00", …]}]` |
| `GET /appointments` | ✓ | user's requests (newest first) |
| `POST /appointments` | ✓ | request `{doctorId, date, time, reason?}` |
| `POST /appointments/{id}/cancel` | ✓ | cancel a pending request |

### Example: `GET /doctors?search=card&city=Beirut&page=2`

```json
{
  "items": [
    {
      "id": "d17",
      "name": "Rana Khoury",
      "specialtyId": "cardiology",
      "specialtyName": "Cardiology",
      "city": "Beirut",
      "rating": 4.8,
      "reviewCount": 132,
      "experienceYears": 11,
      "consultationFee": 60.0,
      "isAcceptingNewPatients": true,
      "nextAvailableAt": "2026-09-25T15:00:00Z",
      "photoUrl": "https://…/d17.jpg"
    }
  ],
  "page": 2,
  "total": 6,
  "hasMore": false
}
```

### Error contract

Every error response has the same shape:

```json
{ "message": "User-safe sentence the UI may render." }
```

Validation failures (HTTP 422) add field errors:

```json
{
  "message": "Validation failed.",
  "errors": {
    "time": ["This slot is not offered by the provider."]
  }
}
```

`DioExceptionMapper` turns statuses into the domain taxonomy
(`Unauthorized/Forbidden/NotFound/Validation/Server`) and passes the
server `message` through as `serverMessage` — the UI shows the backend's
wording when it exists, falling back to local defaults. The mock backend
guarantees these strings are safe to render (never stack traces) — the
same guarantee a real backend must honor.

## Mock backend internals

| File | Role |
| --- | --- |
| `mock_backend_adapter.dart` | Dio `HttpClientAdapter`: honors cancellation, applies `BackendConditions`, delegates to the database, serializes JSON |
| `mock_database.dart` | deterministic seed (72 providers across 10 specialties, 5 cities, weekly schedules), token store with lazy expiry pruning, full validation (future dates, offered slots, double-booking) |
| `backend_conditions.dart` | immutable condition record (offline, latency, forceStatus, malformedResponse, timeoutAfter) — with a sentinel-based `copyWith` so nullable fields can be *cleared* |
| `mock_http_error.dart` | typed error carrying status + JSON body |

Notable behaviors, all covered by tests:

- **Tokens are self-describing** (`mt_<userId>_<expiryMs>`): an expired
  token is rejected with `401 token_expired` even after it was pruned from
  the active store — mirroring signed-JWT semantics.
- **Timeout simulation returns a response whose byte stream never
  delivers** — Dio's `receiveTimeout` on `BaseOptions` is the component
  that aborts the request, exactly like a stalled socket.
- **Offline is a socket-level `DioException.connectionError`**, not a fake
  status code.

## Swapping in a real backend

`lib/presentation/providers/infrastructure_providers.dart`:

```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.your-backend.test/v1', …));
  dio.httpClientAdapter = MockBackendAdapter(          // ← replace
    readConditions: () => ref.read(backendConditionsProvider),
    database: ref.watch(mockDatabaseProvider),
  );
  dio.interceptors.add(AuthInterceptor(…));
  return dio;
});
```

Delete the adapter line (Dio's default platform adapter is restored), point
`baseUrl` at the real service, and ship — repositories, mappers, providers
and tests that run against the contract (rather than the seed) are
unchanged.

## Backend contract checklist (for a Laravel implementation)

- `Accept: application/json` on every request (already sent by the app).
- Errors always `{message, errors?}` — never HTML.
- 401 with a valid-looking token means "session expired" (the interceptor
  depends on this to sign the user out gracefully).
- `/auth/me` returns the session for token verification on boot.
- Pagination metadata: `page`, `total`, `hasMore` (page-based, 20/page).
- Times as `HH:mm` strings, dates as `YYYY-MM-DD`, timestamps as ISO-8601.
