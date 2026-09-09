# FitOS 0.1 TestFlight Metadata

Copy-ready release text for the first local-first beta. Recheck against the submitted build before uploading.

## Beta App Description

FitOS is an adaptive strength-training app for people whose real gym week rarely matches a perfect calendar split.

Instead of assuming you completed the workout you planned, FitOS uses the sets you actually logged to estimate recent muscle stimulus, remaining training debt, and recovery. Tap **Build Today's Workout** and FitOS constructs a session around what still needs useful work, while respecting your available time, equipment, exercise preferences, and how ready you feel today.

The beta also includes workout history and strength trends, conservative progressive-overload guidance, body-measurement trend smoothing, guided repeat measurements, quick macro logging, an optional read-only Apple Health connection, deterministic weekly coaching summaries, explicit AI-context sharing, and local backup/restore.

FitOS 0.1 is intentionally local-first. No account is required and cloud account creation is disabled in this beta.

## What to Test

Please focus on whether **Train Today makes better decisions than a rigid weekly split**.

### 1. The core adaptive loop
1. Complete onboarding.
2. Log a workout, but intentionally leave one planned area under-trained—for example, do chest/shoulders but little direct triceps or no abs.
3. Return to Today and build another workout.
4. Check whether FitOS prioritizes fresh, under-dosed muscle groups instead of blindly repeating the previous session.

Please report cases where FitOS recommends a muscle/exercise that clearly feels wrong given the previous 2–3 sessions.

### 2. Real gym constraints
Try different session lengths and equipment presets. Mark a few exercises **Prefer** or **Avoid** in Settings. Confirm the generated workout respects those choices. During a workout, try Replace and Skip.

### 3. Readiness
Build the same general session with Low, Normal and High readiness. Low should reduce today's workload and keep more reps in reserve. High should allow harder working sets but should not invent extra weekly volume.

### 4. Progression
Repeat an exercise across workouts and check the previous-performance and suggested-load guidance. Please flag suggestions that are obviously too aggressive or too conservative.

### 5. Body-data noise
Use the guided repeat-measurement flow for waist/arm/chest/thigh measurements. Add several normal readings and, if comfortable, one intentionally unusual test reading. The raw value should remain visible without immediately dominating the smoothed trend.

### 6. Apple Health
Test both paths: decline Health access, and grant only the Health permissions you are comfortable sharing. FitOS should remain usable either way and should not create duplicate imported body records after repeated syncs.

### 7. Feedback metrics
After completing a FitOS-generated session, rate how useful it was from 1–5. If the rating is 1–3, choose what was wrong. Check Settings → Beta Metrics to confirm the rating and generated-exercise acceptance are reflected.

### 8. Local backup
Export a FitOS backup to Files/iCloud Drive, add or change some local data, then import the backup. FitOS must show backup details and require explicit confirmation before replacing current data. The backup file is plain JSON, so please treat it as sensitive fitness information.

## Highest-value feedback

When reporting a bad generated workout, please include:

- what you trained in the previous 2–3 sessions
- what you expected FitOS to recommend instead
- selected duration and equipment preset
- readiness selection
- which generated exercises you replaced or skipped
- why the recommendation was wrong (fatigue, wrong muscle priority, disliked movement, equipment unavailable, too much/too little volume, etc.)

Screenshots are useful when they do not expose information you do not want to share.

## Beta Review Notes

- **No login or test account is required.**
- Cloud account creation is intentionally disabled in the FitOS 0.1 beta.
- The primary reviewer path is: onboarding → Today → Build Today's Workout → Start Workout → complete sets → Finish → return to Today.
- Apple Health access is optional. Declining it does not block the app.
- HealthKit access is read-only for selected body/recovery information.
- The app has no advertising SDK and no third-party analytics SDK in this beta.
- Share AI Context is user initiated and uses the iOS share sheet; the app does not automatically send context to an AI provider.
- Local backup export is user initiated and produces an unencrypted JSON file.

## Suggested Internal Tester Message

FitOS is testing one main idea: your workout plan should adapt to what you **actually did**, not what Monday/Tuesday/Wednesday said you were supposed to do.

For the first few workouts, please use it normally—even if you skip exercises, stop early, or change movements because the gym is busy. Those imperfect sessions are exactly what we need to test. After each generated workout, rate whether FitOS's recommendation was genuinely useful.

The most valuable bug report is not “I didn't like it”; it is “I trained X and Y recently, FitOS recommended Z, but I expected A because ___.”

## App Store Connect fields still requiring owner input

- beta review contact name/email/phone
- public Privacy Policy URL
- final App Icon
- support URL if different from the repository
- Apple Developer signing/team information
- any required App Store privacy questionnaire selections
