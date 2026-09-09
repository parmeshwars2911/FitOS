# FitOS

**FitOS is an adaptive fitness operating system for iPhone.** It tracks what you actually trained, estimates muscle-level training debt and recovery, builds the next workout around what your program is missing, and combines training, body and nutrition history into a deterministic coaching context.

The product principle is **math first, LLM second**: deterministic code owns calculations and data-quality rules; AI consumes an explicit, versioned context instead of inventing facts from raw logs.

## What exists today

- Swift `TrainingEngine` package with automated tests
- rolling 7-day effective-set tracking
- compound-exercise muscle contribution model
- recovery + training-debt priority scoring
- adaptive **Train Today** workout generator
- workout logger for sets, reps, load and RIR
- local workout history and persistence
- editable weekly muscle-volume targets
- body measurement logging and trend charts
- read-only Apple Health integration for selected body and recovery signals
- structured nutrition logging with calorie/protein/carbs/fat targets
- deterministic cross-domain `CoachContext` + `WeeklyReview`
- explicit AI-context JSON export through the native iOS share sheet
- versioned cloud snapshot contract with stale-write protection
- Supabase email-OTP account flow with auth tokens stored in iOS Keychain
- safe cloud backup, conflict detection and explicit restore UI
- read-only MCP contract design for future external AI access

Cloud features are **deployable but intentionally unprovisioned** in the checked-in defaults. The app remains fully local-first until a dedicated FitOS backend is configured.

## Run the iOS app

The repository uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) so the Xcode project is generated from the checked-in `project.yml` instead of committing a large `.xcodeproj` file.

```bash
brew install xcodegen
xcodegen generate
open FitOS.xcodeproj
```

Choose an iPhone simulator in Xcode and run the `FitOS` scheme.

## Run the engine tests

```bash
swift test
```

CI runs the package tests, regenerates the Xcode project, and builds the full iOS simulator application before feature PRs are merged.

## Current product loop

```text
workouts ───────────────┐
body + Apple Health ────┼──→ deterministic FitOS state ──→ adaptive workout
nutrition ──────────────┘                 │
                                          ├──→ weekly review
                                          ├──→ explicit AI context export
                                          └──→ versioned cloud snapshot
```

## Cloud activation

FitOS does not reuse another application's backend and does not commit live backend credentials.

To activate cloud backup for a build, provision a dedicated Supabase project and follow:

- [`docs/CLOUD_DEPLOYMENT.md`](docs/CLOUD_DEPLOYMENT.md) — backend, OTP, RLS, Xcode configuration and acceptance tests
- [`docs/MCP_CONTRACT.md`](docs/MCP_CONTRACT.md) — external AI/MCP security boundary

## Next milestones

1. provision a dedicated FitOS staging backend and run the full cloud acceptance test
2. validate the adaptive workout loop and data-entry UX on real iPhones/TestFlight
3. add deliberate multi-device merge semantics only if real usage requires them
4. deploy a separately authorized, read-only MCP/API surface for `CoachContext`
5. evaluate built-in AI explanations against deterministic FitOS facts
6. production privacy/account-deletion/monitoring hardening

See `docs/ARCHITECTURE.md`, `docs/MVP.md`, and `docs/APP_CORE_LOOP.md` for the broader product and technical direction.
