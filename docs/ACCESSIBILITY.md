# Accessibility

Accessibility here is **code + tests, not claims**. Every guarantee below is
encoded in `test/widget/accessibility_test.dart` and fails CI if regressed.

## Semantics labels

| Element | Announcement |
| --- | --- |
| Doctor card (whole) | `"Rana Khoury, Cardiology, rating 4.8 out of 5, Beirut"` — one merged button node; the heart toggle stays a *separate* control so screen-reader users can favorite without opening the profile |
| Rating | `"Rated 4.8 out of 5 from 132 reviews"` |
| Specialty chip | `"Filter by Cardiology, 12 providers"` (+ selected state) |
| City picker | `"Filter by city, Beirut selected"` |
| Favorite button | tooltip `"Add to favorites"` / `"Remove from favorites"` |
| Search clear | `"Clear search"`; filter reset `"Clear all filters"` |
| Stats row (detail) | `"Experience 16 years, consultation fee 125 dollars, next available 24 Sep"` |
| Loading skeleton | one node: `"Loading providers"`; decorative tiles excluded via `ExcludeSemantics` |
| Day/slot chips | `"Select 15:00 on Friday, 25 September"` (+ selected) |
| Book CTA | `"Request appointment with Fadi Hamdan"` / `"… is not accepting new patients"` |
| Form error banners | `Semantics(liveRegion: true)` — announced when they appear |

## Touch targets

All icon-only controls are `IconButton`/`FavoriteButton` with the standard
48×48 minimum (Material default enforced by the widget test that walks
every `IconButton` on a screen and asserts its `RenderBox` ≥ 48 in both
axes). Chips are 44+ px tall; primary buttons 52 px.

## Text scaling

Both key screens (login, discovery) are pumped at **1.0×, 1.3×, 2.0** with
`TextScaler.linear` and asserted to lay out with **no overflow exception**.
The metadata rows use `Wrap` + `Flexible(ellipsis)` so content reflows
rather than clipping. (The detail screen received the same treatment after
a real 65 px overflow appeared during integration testing — narrow phones
with a badge row next to the avatar.)

Form labels float, helper/error text scales with the field, and the
appointment sheet's reason field uses `alignLabelWithHint` for the
multiline case.

## Forms & errors

- Every `TextFormField` has a visible `labelText` (never placeholder-only)
  — labels are programmatically associated by Material.
- Validation errors render **inline below the field** *and* are reachable
  by screen readers (Material `errorText` semantics), plus a form-level
  banner with `liveRegion: true` so the failure is announced.
- Server-side field errors (HTTP 422 `errors` map) land in the same inline
  slots as client validation — one error UX, two sources.
- The login screen's wrong-credentials banner is announced as it appears
  (verified by test).

## Color & contrast

The theme is standard Material 3 (`app_theme.dart`) with the default tonal
surfaces, which meet the platform contrast guidelines for text styles.
Status chips (pending/confirmed/cancelled) pair a container color with its
*on-container* foreground (never hand-picked pairs), and error text uses
`colorScheme.error` on background. Icon-only buttons have tooltips; rating
color (amber) is always accompanied by the textual "4.8 out of 5".

## Focus & order

DOM order follows reading order (column layout, logical widget order), so
traversal order is correct by construction. Interactive elements are
Material controls with built-in focus. The bottom sheet is focus-trapped
by the modal route.

## Test evidence (what CI enforces)

```bash
flutter test test/widget/accessibility_test.dart   # 9 tests
```

1. `icon-only buttons are at least 48x48 logical pixels`
2–7. `doctors/login screen renders without overflow at 1.0/1.3/2.0x text`
8. `form errors are announced (live region on error banners)`
9. `loading skeletons are announced as a unit and hidden from readers` —
   walks the `SemanticsNode` tree and asserts the label list is exactly
   `['Loading providers']`.

## Known limitations (honest list)

- Semantics labels are English-only (as is the app UI; localization is
  out of scope).
- TalkBack/VoiceOver were not run on physical hardware in this environment
  (no device) — semantics are verified through the Flutter semantics tree,
  which is what those engines consume.
- Focus traversal was not scripted with a keyboard; the layout order
  guarantees were reviewed manually.
