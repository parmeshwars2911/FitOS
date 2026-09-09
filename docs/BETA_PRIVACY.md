# FitOS Beta Privacy Data Map

This file describes the intended product behavior for engineering and App Store Connect preparation. It is not a substitute for a jurisdiction-specific legal privacy policy.

## First TestFlight beta

The first beta is intentionally local-first. `FITOS_CLOUD_ACCOUNTS_ENABLED` is `NO`.

### Stored on the user's iPhone

- workout sessions, exercises, sets, reps, load and RIR
- generated-workout adherence records
- body measurements and user-set muscle targets
- nutrition entries and nutrition targets
- onboarding state and HealthKit-enabled preference
- optional imported Apple Health measurements used by FitOS

These records are used to provide the app's fitness tracking, trend calculations and adaptive workout recommendations.

### Apple Health

HealthKit access is optional and permission-scoped. FitOS currently reads selected body/recovery metrics for fitness context. The app remains usable if Health permission is declined. HealthKit permission status and access remain controlled by iOS.

### AI sharing

“Share AI Context” is a user-initiated iOS share-sheet action. FitOS creates a derived coaching-context JSON document locally and does not choose or contact an AI provider automatically. Data leaves FitOS only after the user explicitly selects a destination in the system share sheet.

### Cloud

The repository contains cloud backup/auth code, but cloud accounts are disabled in the first beta build. Empty Supabase credentials alone are not the safety mechanism; `FITOS_CLOUD_ACCOUNTS_ENABLED = NO` is an additional explicit release gate.

### Tracking and advertising

The first beta includes no advertising SDK, cross-app tracking SDK or third-party analytics SDK. The privacy manifest declares `NSPrivacyTracking = false`.

## Required-reason API

FitOS uses `UserDefaults` / `AppStorage` for app-local preferences such as onboarding and feature state. `App/PrivacyInfo.xcprivacy` declares `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1` for app-only reads/writes.

## If cloud is enabled later

Before changing the cloud-account build gate:

1. Implement in-app account deletion.
2. Provision and security-review the dedicated backend.
3. Update the public privacy policy.
4. Reassess App Store Connect privacy answers because data transmitted to the developer's backend is no longer purely on-device.
5. Reassess this privacy manifest if new required-reason APIs, SDKs or tracking behavior are added.
6. Keep MCP / external-AI access a separate explicit opt-in from ordinary FitOS cloud backup.

## Data minimization principles

- request only HealthKit scopes used by visible product features
- keep raw deterministic fitness calculations separate from LLM interpretation
- never include auth tokens, API keys or cloud credentials in AI context export
- do not sell fitness or health data
- do not use HealthKit-derived data for advertising
- prefer user-visible export and deletion controls over hidden data flows
