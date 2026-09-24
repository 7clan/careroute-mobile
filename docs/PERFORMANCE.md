# Performance

Performance work is applied **where it matters in this app** (a paginated
image-heavy list) and documented honestly — no speculative optimization.

## List virtualization

`DoctorsScreen` renders its feed with `ListView.builder` + a `+1` footer
item (load-more state). Only visible cards are built and laid out; the
assertion in `doctors_screen_test.dart` deliberately checks "a screenful
(3+), not the full dataset" — the 72-provider seed never all materializes.
The specialty chip row and day picker are also lazy `ListView.separated`s
(horizontal).

`const` is used pervasively for static subtrees (skeletons, icons,
spacing) so rebuilds skip identical subtrees.

## Request-level performance

- **Debounced search (350 ms)** — `core/utils/debouncer.dart`, a pure
  class with its own timing tests. Every keystroke reschedules one timer;
  the network sees one request per burst, not one per keypress.
  `clearSearch()` cancels the timer — intent is unambiguous.
- **Pagination (20/page)** — the API returns `page/total/hasMore`; the next
  page triggers 320 px *before* the list end (`ScrollNotification` listener),
  so pages load while the user is still scrolling. Load-more failures keep
  the list visible with a retry footer — no scroll position is ever lost.
- **Stale-response guard** — `DoctorsController._requestSeq` drops
  responses that belong to an outdated filter set. Fast typing can't
  produce interleaved results.
- **Session-cached reference data** — `specialtiesProvider` /
  `citiesProvider` are `FutureProvider`s: fetched once per session, not per
  screen visit.

## Rebuild scoping

The list's biggest rebuild hazard is the favorite toggle. Instead of
watching the whole `favoritesProvider` in every card:

```dart
final isFavoriteProvider = Provider.family<bool, String>(
  (ref, id) => (ref.watch(favoritesProvider).value ?? {}).contains(id),
);
```

Each `FavoriteButton` watches its own `isFavoriteProvider(doctor.id)`.
Toggling one heart rebuilds exactly one button — the 19 other visible cards
are untouched. The "N found" counter similarly watches only
`doctorsProvider`, and the filter bar only `doctorFiltersProvider`, so
scrolling doesn't rebuild chips and typing doesn't rebuild cards.

## Image memory

`DoctorAvatar` uses `cached_network_image` with:

- `memCacheWidth: (size * 2).round()` — decodes at ~2× display size (a 64 dp
  avatar decodes a 128 px bitmap, not the source's possible 1024 px).
  Memory cache stays small regardless of source resolution.
- disk cache across sessions,
- `placeholder`/`errorWidget` → **initials fallback** — offline or a dead
  image URL never renders a broken box; the UI stays functional.

## Rendering choices

- **`Wrap` over `Row` for metadata lines** (fee · next-visit · status
  badges): content reflows to a second line on narrow phones and at large
  text scales instead of triggering flex overflow. Chosen after a real
  65 px overflow surfaced in the detail screen during the integration test
  (fixed + regression-covered by the text-scaling matrix).
- `NotificationListener<ScrollNotification>` (not a scroll controller) for
  the pre-load trigger — no controller bookkeeping, no listener leaks.
- `Hero` transitions on avatars give perceived speed for free.
- Skeletons are a single `AnimationController` per tile with `repeat(reverse)` —
  cheap opacity fade on existing layers; tiles are excluded from semantics.

## What was measured

The test suite encodes the measurable claims (lazy building, debounce
timing, retry recovery, no-overflow up to 2.0× text scale). Memory and
frame timings were not profiled with DevTools in this environment — no
numbers are claimed that weren't measured. The Flutter DevTools steps to do
so (performance overlay, memory chart) are listed in
[RELEASE.md](RELEASE.md) for anyone who wants to reproduce on hardware.

## Non-optimizations (on purpose)

- No `RepaintBoundary` golf: cards are cheap and few are visible.
- No manual `select`/proxy beyond the family provider above: measured
  rebuild scopes are already tight.
- No offline HTTP cache layer: favorites and theme (the persisted state)
  use local storage; the API is expected online (spec'd behavior, surfaced
  honestly via the error taxonomy).
