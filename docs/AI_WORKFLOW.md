# AI Workflow — how assistance was used, and how everything was verified

This project was developed **with AI assistance** (Claude via the Z.ai
agent environment) under a senior-engineer-supervised workflow. This
document discloses what the AI did, what was verified by actually running
commands, and what a reviewer should check. Honesty is the point: nothing
below is claimed without a command output behind it.

## Division of labor

| Work | Who/what |
| --- | --- |
| Architecture, layering, provider design, error taxonomy | AI-drafted, iterated against real test/build output |
| All Dart/Kotlin/YAML/Markdown source | AI-written under instruction, then **compiled, analyzed, formatted, tested, and built** by tools |
| Requirement interpretation | from `PROJECT_SPEC.md` (repo owner's document, unmodified) |
| Verification & honesty gates | actual command runs, output captured in this session (see below) |

## The workflow loop

1. **Read the spec and existing code first.** Every feature decision traces
   back to `PROJECT_SPEC.md` or an existing file.
2. **Write code, then immediately run the tools.** `dart format`,
   `flutter analyze`, `flutter test` after every meaningful change — the
   same gates CI enforces. No lint suppressions were used anywhere.
3. **Fix root causes, not symptoms.** Examples from this codebase:
   - a nullable-`copyWith` bug meant `setForceServerError(false)` could
     never clear the field → fixed with a sentinel `Object?` parameter +
     regression covered by the retry-recovery widget test;
   - a real 65 px overflow on 411 px-wide phones in the detail screen →
     reflowed with `Wrap` + `Flexible`, covered by the text-scaling matrix;
   - integration-test failures traced to *actual* framework behaviors
     (Dio's timer-based delivery; `ensureVisible` stale render offsets)
     and fixed in the tests with explanatory comments, not by loosening
     assertions.
4. **Never fake results.** Where the environment couldn't verify something
   (iOS builds, TalkBack on hardware, production signing), the docs say so
   explicitly (see RELEASE.md and ACCESSIBILITY.md "limitations" sections).

## What was actually run & verified (this machine, 2026-09-23/24)

| Claim | Verification |
| --- | --- |
| `dart format --output=none --set-exit-if-changed .` clean | exit 0 — "Formatted 97 files (0 changed)" |
| `flutter analyze` clean | "No issues found! (ran in 1.4s)" |
| `flutter test` — 131 passing | "00:21 +131: All tests passed!" (after 4 failing tests were root-caused and fixed) |
| Release APK builds | `✓ Built build/app/outputs/flutter-apk/app-release.apk (19.9MB)` |
| Release AAB builds | `✓ Built build/app/outputs/bundle/release/app-release.aab (19.7MB)` |
| No secrets in history | manual `git log -p` review + grep for token patterns before push |
| Android SDK/NDK/JDK toolchain | installed and used by the successful builds above |

## What AI assistance did NOT do

- No code was pushed that failed the gates above.
- No test was written to merely pass (all assertions encode spec'd
  behavior; the golden-path test exercises the real router, Riverpod
  wiring and Dio pipeline end-to-end).
- No fabricated screenshots, star counts, or store/publication claims.
- No claims about performance numbers that weren't measured.
- `PROJECT_SPEC.md` and the original README intent were preserved (the
  README was rewritten to reflect the *completed* implementation, as the
  original explicitly said "implementation is in progress").

## How a reviewer can re-verify in 5 minutes

```bash
git clone https://github.com/7clan/careroute-mobile && cd careroute-mobile
flutter pub get
dart format --output=none --set-exit-if-changed .   # exit 0
flutter analyze                                    # no issues
flutter test                                       # 131 passed
flutter build apk --release --target-platform android-arm64
```

Then read any doc claim and check its source file — every doc links to
the files that back it.

## AI-specific engineering notes

Working with AI on a codebase has failure modes; the workflow guarded
against them:

- **Hallucinated APIs**: the analyzer is the guard — code that calls
  non-existent Flutter/Dio/Riverpod APIs doesn't compile. (Real example:
  an early draft used a deprecated `pipelineOwner` accessor; it was
  replaced with the non-deprecated `renderViews.first.owner` path.)
- **Tests that pass for the wrong reason**: assertions were written
  against *behavior* (state transitions, widget presence, exception
  types), then deliberately broken during development to confirm they
  can fail.
- **Escape-corruption in generated strings** (e.g. `\$` vs `$` in
  interpolated UI strings): a repo-wide grep audit was performed; the one
  intentional literal-dollar (currency) is `'\$${…}'` in
  `doctor_card.dart` and `r'$' + …` in `doctor_detail_screen.dart`,
  both correct Dart.
