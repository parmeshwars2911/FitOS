# FitOS

**FitOS is an adaptive fitness operating system for iPhone.** It tracks what you actually trained, estimates muscle-level training debt and recovery, and builds the next session around what your recent training is missing instead of assuming you followed a fixed weekday split.

The product principle is **math first, LLM second**: deterministic code owns workload, recovery, progression, body-trend, nutrition and data-quality calculations. AI consumes an explicit context instead of inventing facts from raw logs.

## Product promise

> Train however life allows. FitOS sees what you actually completed, what is still under-dosed, what has recovered, and what constraints you have today—then rebuilds the next workout.

The original regression scenario is protected by automated tests: after a press-heavy session where chest/shoulders were trained but triceps, abs and traps were under-dosed, the next generated session must prioritize the missed areas and must not immediately repeat bench press.

## What exists today

### Adaptive training
- rolling 7-day effective-set tracking by muscle
- fractional secondary-muscle credit for compound exercises
- muscle-level training debt + recovery priority scoring
- adaptive **Train Today** generator
- duration and equipment constraints, including bodyweight-only sessions
- Low / Normal / High session readiness with bounded set-budget/RIR changes
- explicit exercise **Prefer / Neutral / Avoid** preferences
- 55+ canonical exercises with stable IDs and shared core/app definitions
- previous-performance display and deterministic double progression
- estimated 1RM / strength trends
- generated-exercise acceptance tracking
- 1–5 generated-workout usefulness feedback + beta metrics

### Workout experience
- sets, reps, load and RIR logging
- only sets explicitly marked DONE are persisted as completed work
- previous-set values inline
- add / replace / skip exercise
- rest timer
- dirty-workout dismissal protection with explicit discard confirmation
- on-device active-workout autosave and Resume Workout after interruption/relaunch
- local workout history
- editable weekly muscle targets and focus priorities

### Body and recovery
- body weight, waist, chest, biceps, thigh and body-fat logging
- rolling mean for weight and robust median smoothing for noisier measurements
- variability + Low / Medium / High trend confidence
- guided repeated-measurement protocols before saving a longitudinal observation
- optional read-only Apple Health import for selected body metrics, sleep, resting HR and HRV
- HealthKit signals are contextual only; they do not silently rewrite training yet

### Nutrition and coaching
- structured calorie / protein / carbs / fat logging and user-defined targets
- deterministic cross-domain `CoachContext`
- deterministic `WeeklyReview` with data-confidence rules
- explicit AI-context JSON export through the native iOS share sheet

### Data and platform foundation
- local-first persistence
- versioned local JSON backup/export + validated, confirmed restore
- versioned cloud snapshot contract with stale-write protection
- Supabase email-OTP / backup / restore implementation with Keychain token storage
- read-only MCP contract design for a future separately authorized external-AI surface

Cloud account creation is **deliberately disabled in the first TestFlight build**. The cloud code is present for later activation, but enabling it is blocked until account deletion, backend deployment, privacy disclosures and security acceptance tests are complete.

## Run the iOS app

FitOS uses [XcodeGen](https://github.com/yonaskolb/XcodeGen), so the Xcode project is generated from `project.yml`.

```bash
brew install xcodegen
xcodegen generate
open FitOS.xcodeproj
```

Choose an iPhone simulator and run the `FitOS` scheme.

## Run tests

```bash
swift test
```

Every feature PR must pass:

1. TrainingEngine tests
2. beta privacy/release metadata validation
3. XcodeGen project generation
4. full iOS simulator build

## Current product loop

```text
actual workouts ──────────────┐
body trends + Apple Health ───┼──→ deterministic FitOS state ──→ Train Today
nutrition ────────────────────┘              │
                                              ├──→ progression guidance
preferences + readiness ──────────────────────┤
                                              ├──→ weekly review
                                              ├──→ explicit AI context export
                                              └──→ beta feedback / acceptance metrics
```

## FitOS 0.1 beta policy

The first beta is deliberately narrow:

- iPhone first
- local-first
- no ads or third-party analytics SDK
- no cloud account creation
- no full food database/barcode scanner
- no Apple Watch app
- no medical advice
- no autonomous nutrition changes

Testers can export a versioned local FitOS backup before reinstalling. Backup JSON is not encrypted and is explicitly treated as sensitive fitness data.

## TestFlight blockers outside the codebase

The codebase has release gates, but these still require product/account-owner work:

- production App Icon / asset catalog
- public hosted Privacy Policy URL
- Apple Developer Program / App Store Connect setup, signing and HealthKit capability
- physical-device acceptance testing

See [`docs/TESTFLIGHT_CHECKLIST.md`](docs/TESTFLIGHT_CHECKLIST.md).

## Later platform work

After the adaptive loop is validated with real users:

1. provision a dedicated FitOS staging backend
2. add in-app account deletion and complete backend privacy/security gates
3. activate cloud accounts intentionally
4. expose a separately authorized read-only MCP/API surface
5. evaluate built-in AI explanations/Q&A against deterministic FitOS facts
6. test monetization only after recommendation usefulness and retention are demonstrated

See `docs/ARCHITECTURE.md`, `docs/MVP.md`, `docs/APP_CORE_LOOP.md`, `docs/CLOUD_DEPLOYMENT.md`, and `docs/MCP_CONTRACT.md` for the broader direction.
