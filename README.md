# FitOS

**FitOS is an adaptive fitness operating system for iPhone.** It tracks what you actually trained, estimates muscle-level training debt and recovery, and builds the next workout around what your program is missing.

The product principle is **math first, LLM second**: deterministic code owns training calculations; AI will later interpret those results, explain recommendations and provide a natural-language interface.

## What exists today

- Swift `TrainingEngine` package
- rolling 7-day effective-set tracking
- compound-exercise muscle contribution model
- recovery + training-debt priority scoring
- adaptive **Train Today** workout generator
- SwiftUI Today dashboard
- workout logger for sets, reps, load and RIR
- starter strength-training exercise catalog
- local on-device workout persistence
- workout history
- automated engine tests for missed-muscle rebalancing

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

## Current product loop

```text
Completed workout history
        ↓
TrainingStateEngine
        ↓
muscle volume + recovery + training debt
        ↓
WorkoutGenerator
        ↓
Build Today's Workout
        ↓
log what was actually completed
        ↓
local persistence
        ↺
```

## Next milestones

1. prove the adaptive workout loop with simulator/TestFlight users
2. add editable goals and weekly muscle-volume targets
3. add bodyweight and measurement tracking
4. HealthKit read/write integration
5. cloud account + sync
6. AI explanations and weekly review
7. MCP/API access
8. subscriptions

See `docs/ARCHITECTURE.md`, `docs/MVP.md`, and `docs/APP_CORE_LOOP.md` for the product and technical direction.
