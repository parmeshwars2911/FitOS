# MVP Scope

## Target user
A gym-goer focused on hypertrophy / recomp who trains 2–6 days per week but does not always follow the planned session exactly.

## Core job
When the user arrives at the gym, tell them what to train today using their actual recent workload rather than a rigid calendar.

## V1 screens

1. **Today**
   - training-state summary
   - highest training debts
   - Build Today's Workout
   - duration/equipment constraints

2. **Active Workout**
   - exercises, sets, reps, load, RIR
   - last-session values inline
   - add/replace/skip exercise
   - rest timer

3. **History**
   - past sessions
   - exercise progress
   - estimated strength trends

4. **Body**
   - body weight
   - waist, arms, chest, thighs
   - trend smoothing
   - measurement instructions

5. **Coach**
   - weekly review
   - “why this workout?”
   - historical Q&A

6. **Settings / Connections**
   - goals
   - target weekly volume
   - Apple Health
   - MCP/API permissions
   - subscription

## Explicit non-goals for first TestFlight

- full MyFitnessPal-style food database
- calorie barcode scanner
- social network
- Apple Watch app
- exercise video content library
- medical advice
- autonomous nutrition changes

## TestFlight success criteria

- 50+ real lifters complete at least 3 logged workouts
- >=40% of retained users use Train Today weekly
- >=30% D14 retention among users who complete onboarding + first workout
- users accept >=60% of generated exercises without replacement
- subjective recommendation usefulness >=4/5 among retained testers
