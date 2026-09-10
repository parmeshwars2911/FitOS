# FitOS TestFlight Release Checklist

This is the release gate for the first iPhone beta. It complements CI; it does not replace Apple Developer / App Store Connect steps that require the account owner.

## First beta policy

FitOS 0.1.x is a **local-first beta**. Cloud account creation must remain disabled until account deletion, backend deployment and the corresponding privacy disclosures are complete.

Repository defaults:

- marketing version: `0.1.0`
- build: `1`
- bundle ID: `com.parmeshwars2911.FitOS`
- cloud accounts: `FITOS_CLOUD_ACCOUNTS_ENABLED = NO`
- HealthKit: optional, read-only selected body/recovery data
- third-party analytics / ads: none
- local backup: explicit user export/import of versioned JSON

CI intentionally fails if the cloud-account flag is changed from `NO`. Enabling accounts later must be a deliberate release change that also changes this gate.

## Code gates

Before archiving:

- [ ] `main` CI is green.
- [ ] `swift test` passes.
- [ ] iOS simulator build passes.
- [ ] `App/PrivacyInfo.xcprivacy` passes `plutil -lint`.
- [ ] marketing version and build number are set and the build number has not already been uploaded.
- [ ] HealthKit purpose text still describes only data the app actually reads.
- [ ] no Supabase service-role secret, user token, production credential or private signing file is committed.
- [ ] cloud account flag is `NO` for the first beta.

## Apple-account gates

- [ ] Active Apple Developer Program membership.
- [ ] App ID / App Store Connect record exists for `com.parmeshwars2911.FitOS`.
- [ ] Correct Apple Developer Team is selected for signing in Xcode.
- [ ] HealthKit capability is enabled for the App ID and provisioning profile.
- [ ] A 1024×1024 production App Icon and required asset-catalog configuration are present. **Current repo blocker until added.**
- [x] A public Privacy Policy exists in `PRIVACY_POLICY.md` and matches the local-first 0.1 beta data flow.
- [ ] Enter `https://github.com/parmeshwars2911/FitOS/blob/main/PRIVACY_POLICY.md` in the App Store Connect Privacy Policy URL field.
- [ ] App Store Connect contact information and TestFlight “What to Test” copy are complete.

## Physical-device acceptance test

Simulator success is not enough for HealthKit, Files and real gym use. On at least one supported iPhone:

### First launch / persistence
- [ ] clean install shows onboarding
- [ ] onboarding creates conservative editable muscle targets
- [ ] relaunch preserves settings and local data

### Adaptive workout loop
- [ ] manual workout can be logged and survives relaunch
- [ ] Train Today changes after a partially completed workout
- [ ] press-heavy session with under-dosed triceps/abs/traps does not immediately regenerate bench
- [ ] generated exercises respect selected equipment
- [ ] Bodyweight-only preset generates only bodyweight-compatible work
- [ ] Prefer / Avoid exercise choices affect the next generated session
- [ ] Low readiness reduces today's work and High readiness does not add extra weekly sets
- [ ] previous loads/reps appear in the next workout
- [ ] progressive-overload recommendation is sensible for an exercise with history
- [ ] rest timer starts from completed sets
- [ ] exercise replace and skip work
- [ ] unchecked prefilled set rows are not saved when the workout finishes
- [ ] Finish stays disabled until at least one set is marked DONE
- [ ] after editing a workout, swipe-to-dismiss is blocked and Cancel requires destructive discard confirmation
- [ ] an untouched workout can still be cancelled without a discard warning
- [ ] force-quit/relaunch during an active workout restores exercise edits, load/reps/RIR and DONE markers
- [ ] Today shows Resume Workout after an interrupted active session and hides new-workout generation until resume/discard
- [ ] an unfinished recovered draft does not change training debt or plan adherence until Finish is used
- [ ] discarding a recovered draft removes it so the next relaunch does not offer Resume Workout
- [ ] plan-acceptance metric records generated-session outcomes
- [ ] completed generated session produces a usefulness-rating prompt
- [ ] Beta Metrics reflects acceptance and workout ratings
- [ ] Beta Metrics exercise acceptance equals accepted planned exercises / all planned exercises across generated workouts
- [ ] Share beta report opens the system share sheet and does not transmit until the user chooses a destination
- [ ] shared beta-report JSON contains aggregate counts/rates/reason totals but no workout/exercise IDs, set/load/reps, body/nutrition/HealthKit values, account details or device identifiers

### Body / nutrition / HealthKit
- [ ] body measurement guide aggregates repeated tape readings
- [ ] an outlier body reading remains visible but does not dominate the smoothed trend
- [ ] trend confidence changes appropriately as repeated stable data accumulates
- [ ] nutrition entries and targets survive relaunch
- [ ] Apple Health permission can be declined without blocking the app
- [ ] Apple Health permission can be granted and supported metrics import without duplicates
- [ ] HealthKit context does not silently alter the plan

### Data portability / AI
- [ ] Export Local Backup creates a readable FitOS JSON file in Files/iCloud Drive
- [ ] backup warns that the exported file is not encrypted
- [ ] importing a valid backup shows counts before any data changes
- [ ] cancelling import/restore leaves current data untouched
- [ ] confirmed restore recovers workouts, body data, targets, nutrition, plan metrics, preferences and workout ratings
- [ ] confirmed local/cloud restore clears any pre-existing active workout draft
- [ ] unsupported/corrupt backup fails without replacing local data
- [ ] local backup does not alter Apple Health authorization
- [ ] Share AI Context opens the system share sheet and sends no data until the user chooses a destination
- [ ] Cloud & AI shows cloud unavailable/disabled for this beta

## Archive and upload

1. Increment `CURRENT_PROJECT_VERSION` for every new uploaded build.
2. Generate the Xcode project with `xcodegen generate`.
3. Open `FitOS.xcodeproj` and select the correct signing team.
4. Choose a generic iOS device / Any iOS Device target.
5. Product → Archive.
6. In Organizer, Validate App before upload.
7. Distribute App → App Store Connect → Upload.
8. Confirm the build appears under TestFlight and has no missing compliance state.
9. Add internal testers first.
10. Run the physical-device acceptance checklist before inviting external testers.

## Export compliance

FitOS currently uses system-provided networking/security such as `URLSession` HTTPS and Keychain, not proprietary encryption. `ITSAppUsesNonExemptEncryption` is set to `NO` in generated Info.plist settings. Re-evaluate this if a future dependency adds its own cryptography.

The user-exported local backup is plain JSON; it is **not encrypted by FitOS**. This is disclosed in the backup UI. App Store privacy materials should describe the actual beta data flow, not imply that an exported file is protected after the user saves/shares it.

## Before external TestFlight

- [ ] Add concise beta description and concrete “What to Test” instructions.
- [ ] Provide beta review contact details.
- [ ] Confirm privacy-policy URL is accessible without login.
- [ ] Confirm any demo/reviewer path does not require an unavailable backend.
- [ ] Do not enable cloud account creation merely for beta review.

## Before enabling cloud accounts

This is a hard product/review gate:

- [ ] dedicated FitOS Supabase project is provisioned
- [ ] RLS and revision migration is applied
- [ ] email OTP template is configured and end-to-end tested
- [ ] in-app **Delete Account** exists and deletes the authentication account plus associated server data
- [ ] deletion is tested for a user with a cloud backup
- [ ] privacy manifest / App Store privacy answers are updated for data transmitted to the FitOS backend
- [ ] hosted privacy policy is updated
- [ ] cloud security review is complete
- [ ] CI cloud-account gate is deliberately updated in the same reviewed release change

## First beta success metrics

- 50+ real lifters complete at least 3 workouts
- ≥40% of retained users use Train Today weekly
- ≥30% D14 retention after onboarding + first workout
- ≥60% generated-exercise acceptance
- ≥4/5 average generated-workout usefulness among retained testers

For the first small internal cohort, qualitative failure reports are more important than optimizing these percentages prematurely.
