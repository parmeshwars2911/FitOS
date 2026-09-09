# FitOS app core loop

The first iOS milestone exists to prove one behavior before adding the broader platform.

## Core loop

1. **Today** evaluates the rolling training state from completed sessions.
2. The user chooses how much time they have.
3. **Build Today's Workout** asks the deterministic `WorkoutGenerator` for a session.
4. The user starts the session and logs the sets they actually complete.
5. Each set captures reps, load and RIR.
6. On **Finish**, FitOS persists the completed session locally.
7. Training state is recalculated immediately from actual work.
8. The next recommended workout changes accordingly.

This is deliberately different from marking a fixed routine as complete. If a user skips triceps, abs, traps, or half of an exercise, the engine sees the missing stimulus.

## Current boundaries

Included now:
- on-device workout history
- exercise-to-muscle contribution model
- rolling effective sets
- recovery + training debt
- adaptive workout generation
- manual workout logging
- local JSON persistence

Deferred until this loop proves useful:
- account/authentication
- Supabase/cloud sync
- nutrition logging
- body measurements
- HealthKit
- Apple Watch
- subscription/paywall
- LLM explanations and chat
- MCP server

## Why math before AI

The LLM will eventually explain *why* FitOS made a decision and answer natural-language questions. It should not be responsible for calculating volume, recovery, debt, or deterministic progression. Those values stay inspectable and testable in the Training Engine.
