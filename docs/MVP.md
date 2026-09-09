# FitOS 0.1 MVP Scope

## Target user

A gym-goer focused on hypertrophy / recomp who trains roughly 2–6 days per week but does not reliably execute a fixed weekly split exactly as written.

## Core job

**When the user arrives at the gym, tell them what to train today using what they actually completed recently—not what the calendar says they were supposed to do.**

## Product thesis

A normal routine marks a planned Push Day as complete even if the user leaves before triceps and abs. FitOS instead keeps a rolling muscle-level state:

- effective recent stimulus
- target volume
- remaining training debt
- time-based recovery
- user goal priority
- today's duration/equipment/readiness constraints
- explicit exercise preferences

The generated session should repair the highest-value fresh deficits without needlessly repeating recently trained muscles.

## Implemented V1 surfaces

### 1. Today
- muscle training-state summary
- rolling target / effective sets / debt / recovery
- deterministic weekly review
- optional Apple Health context
- duration constraint
- equipment preset
- Low / Normal / High user readiness
- Build Today's Workout
- rationale for generated recommendations
- post-workout usefulness prompt for unrated generated sessions

### 2. Active Workout
- exercises, sets, reps, load and RIR
- recommended starting load when history exists
- previous-session values inline
- add / replace / skip exercise
- rest timer
- generated-plan outcome classification

### 3. History
- past sessions
- prior performance
- estimated 1RM / strength trends
- deterministic double-progression guidance

### 4. Progress / Body
- weight
- waist, biceps, chest, thigh
- optional body-fat percentage
- raw measurements remain visible
- weight rolling mean
- robust median smoothing for noisier tape/body-fat metrics
- trend variability and confidence
- guided repeated-measurement protocols

### 5. Nutrition
- quick structured meal/macro logging
- calories, protein, carbs and fat
- user-defined daily targets
- daily adherence summaries

A large branded-food database, barcode scanner and recipe ecosystem are intentionally not part of this beta.

### 6. Coach / AI bridge
- deterministic `CoachContext`
- deterministic weekly review
- training + body + nutrition facts combined into one stable context
- native Share AI Context flow

Built-in conversational historical Q&A is **not** part of the first beta. It comes only after a secure model/backend path exists.

### 7. Settings / Data
- editable weekly muscle targets
- exercise Prefer / Neutral / Avoid preferences
- Beta Metrics
- local FitOS backup export/import
- Cloud & AI scaffold
- explicit AI-context sharing

Cloud account creation remains disabled for 0.1 TestFlight.

## Core adaptive rules

1. **Actual execution wins.** Only completed sets influence the next state.
2. **Compounds give partial secondary credit.** Bench can contribute to triceps/front delts without pretending it equals direct isolation work.
3. **Training debt is rolling.** Missing work is not lost because a weekday passed.
4. **Recovery gates priority.** A large deficit does not mean a fatigued muscle must be hammered today.
5. **Readiness is bounded.** Low readiness can reduce today's work; High readiness cannot create extra weekly volume.
6. **Preferences are secondary to physiology/constraints.** Prefer is a modest ranking boost; Avoid is a hard generator exclusion.
7. **Progression is conservative.** FitOS uses double progression rather than reacting aggressively to one poor session.
8. **Body measurements are signals, not exact truth.** One outlier reading remains visible but should not dominate coaching.
9. **AI never owns arithmetic.** Deterministic engines calculate facts; AI may later explain them.

## Explicit non-goals for first TestFlight

- full MyFitnessPal-style food database
- calorie barcode scanner
- social network
- Apple Watch app
- exercise video/content library
- medical diagnosis or treatment advice
- automatic calorie prescription/adjustment
- automatic HRV/sleep-driven workout rewrites
- active cloud accounts
- autonomous MCP write access
- subscription/paywall optimization

## Beta instrumentation without third-party analytics

The first beta measures locally:

- generated exercise acceptance ratio
- replaced exercises
- skipped exercises
- generated-workout usefulness rating (1–5)
- proportion of ratings at 4–5

Retention and cohort-level metrics will initially require tester follow-up / beta operations until a deliberate privacy-reviewed analytics strategy is added.

## TestFlight success criteria

Directional targets—not promises:

- 50+ real lifters complete at least 3 logged workouts
- ≥40% of retained users use Train Today weekly
- ≥30% D14 retention among users who complete onboarding + first workout
- users accept ≥60% of generated exercises without replacement
- average subjective recommendation usefulness ≥4/5 among retained testers

For the first small internal cohort, qualitative failure modes are more valuable than optimizing percentages prematurely.

## What must be learned before monetization

We should not optimize a paywall before proving:

1. users repeatedly trust **Build Today's Workout**
2. generated sessions fit real gym constraints
3. skipped/replaced movements fall as preferences/history improve
4. users understand why FitOS changed their session
5. recommendation usefulness remains high after multiple weeks, not just the novelty period

If those behaviors hold, adaptive coaching becomes the natural Pro value layer later.
