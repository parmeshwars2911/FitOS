# FitOS TestFlight Release Checklist

This document is the release gate for the first iPhone beta. It complements CI; it does not replace Apple Developer / App Store Connect steps that require the account owner.

## First beta policy

FitOS 0.1.x is a **local-first beta**. Cloud account creation must remain disabled until account deletion, backend deployment and the corresponding privacy disclosures are complete.

Repository defaults:

- marketing version: `0.1.0`
- build: `1`
- bundle ID: `com.parmeshwars2911.FitOS`
- cloud accounts: `FITOS_CLOUD_ACCOUNTS_ENABLED = NO`
- HealthKit: optional, read-only selected body/recovery data
- third-party analytics / ads: none

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
- [ ] A public Privacy Policy URL exists and matches the actual beta data flow. **Current external blocker until hosted.**
- [ ] App Store Connect contact information and TestFlight “What to Test” copy are complete.

## Physical-device acceptance test

Simulator success is not enough for HealthKit and real gym use. On at least one supported iPhone:

- [ ] clean install shows onboarding
- [ ] onboarding creates conservative editable muscle targets
- [ ] manual workout can be logged and survives relaunch
- [ ] Train Today changes after a partially completed workout
- [ ] generated exercises respect selected equipment
- [ ] previous loads/reps appear in the next workout
- [ ] progressive-overload recommendation is sensible for an exercise with history
- [ ] rest timer starts from completed sets
- [ ] exercise replace and skip work
- [ ] plan-acceptance metric records generated-session outcomes
- [ ] body measurement guide aggregates repeated tape readings
- [ ] an outlier body reading remains visible but does not dominate the smoothed trend
- [ ] nutrition entries and targets survive relaunch
- [ ] Apple Health permission can be declined without blocking the app
- [ ] Apple Health permission can be granted and supported metrics import without duplicates
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

## Before external TestFlight

- [ ] Add concise beta description and concrete “What to Test” instructions.
- [ ] Provide beta review contact details.
- [ ] Confirm privacy-policy URL is accessible without login.
- [ ] Confirm any demo/reviewer path does not require an unavailable backend.
- [ ] Do not enable cloud account creation merely for beta review.

## Before enabling cloud accounts

This is a hard product/review gate, not a nice-to-have:

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

Use the MVP targets already documented in `docs/MVP.md`:

- 50+ real lifters complete at least 3 workouts
- ≥40% of retained users use Train Today weekly
- ≥30% D14 retention after onboarding + first workout
- ≥60% generated-exercise acceptance
- ≥4/5 recommendation usefulness among retained testers

For the first small internal cohort, qualitative failure reports are more important than optimizing these percentages prematurely.
