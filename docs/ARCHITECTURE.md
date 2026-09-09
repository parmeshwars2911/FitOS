# Architecture

## System layers

### 1. iOS client
SwiftUI app responsible for workout logging, Train Today, body metrics, charts, HealthKit permissions, subscriptions, and local-first caching.

### 2. Training State Engine
Pure Swift domain module. It must remain deterministic and independently testable.

Inputs:
- completed workouts
- exercise-to-muscle contribution maps
- rolling muscle targets
- RIR/RPE quality signal
- time since last stimulus
- user goal priorities
- session constraints

Outputs:
- effective rolling sets per muscle
- training debt
- recovery score
- priority score
- generated next workout
- machine-readable rationale

### 3. Data platform
Planned Supabase/Postgres backend for users, workout history, exercise definitions, body measurements, nutrition summaries, AI permissions, and sync.

The iOS app should be usable offline; sync is eventual rather than blocking the workout flow.

### 4. AI orchestration
The LLM receives a compact structured snapshot from the deterministic engine. It can explain *why* a workout was produced, answer historical questions, and translate natural-language logging into structured writes.

The LLM should never be the source of truth for set counts, recovery calculations, or user history.

### 5. MCP/API gateway
Permission-scoped interface for external assistants.

Initial read tools:
- `get_training_state`
- `get_recent_workouts`
- `get_muscle_volume`
- `get_strength_trends`
- `get_body_metrics`
- `get_nutrition_summary`
- `get_current_goals`

Initial write tools:
- `generate_next_workout`
- `save_planned_workout`
- `log_workout`
- `log_body_measurement`

Write scopes are separate from read scopes and disabled by default.

## Training priority

V0.1 uses:

`priority = normalized_training_debt × recovery_multiplier × goal_priority`

where recovery multiplier never fully erases debt; it only gates how urgently the muscle should be trained today.

This will evolve with real-user data. The important rule is that algorithm changes remain versioned and evaluable against historical sessions.
