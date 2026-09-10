# FitOS 0.1 — App Store Connect Answer Sheet

Prepared for the **local-first FitOS 0.1 beta**. Recheck this file against the exact archived build before submission. If cloud accounts, remote AI processing, analytics, ads, subscriptions, or other network data collection are enabled later, these answers must be reviewed again before that build ships.

## App identity

- App name: **FitOS**
- Platform: **iOS / iPhone**
- Bundle ID: `com.parmeshwars2911.FitOS`
- Marketing version: `0.1.0`
- Current repository build number: `1`
- Suggested primary category: **Health & Fitness**
- Cloud account creation for 0.1: **Disabled**
- Login required for 0.1: **No**

## URLs

- Privacy Policy URL: `https://github.com/parmeshwars2911/FitOS/blob/main/PRIVACY_POLICY.md`
- Support URL: `https://github.com/parmeshwars2911/FitOS/issues`

The same privacy and support destinations are accessible from Settings inside the app.

## App Privacy questionnaire — current 0.1 answer

### Does this app or its third-party partners collect data from the app?

**Recommended answer for the current 0.1 build: No, we do not collect data from this app.**

Why this matches the current build:

- workouts, body measurements, nutrition, preferences, feedback and active-workout state are processed and persisted on-device
- selected Apple Health data is read only with user permission and processed locally
- cloud account creation / cloud backup are disabled in the release configuration
- there is no advertising SDK or third-party analytics SDK
- FitOS does not automatically upload beta metrics
- **Share beta report** is an explicit user action through the iOS share sheet and contains aggregate product metrics only
- **Share AI Context** is an explicit user action through the iOS share sheet; FitOS does not embed or automatically send data to an AI provider
- local backup export is an explicit user-controlled file export; FitOS does not automatically upload the file to a storage provider

Apple defines data as “collected” for App Privacy when it is transmitted off-device in a way that lets the developer or an integrated third-party partner access it for longer than needed to service a real-time request. Apple also states that data processed only on-device is not considered collected for this disclosure.

Official reference: `https://developer.apple.com/app-store/app-privacy-details/`

### Tracking

- Does FitOS track users across apps/websites for advertising or advertising measurement? **No**
- Does FitOS share data with data brokers? **No**
- Is AppTrackingTransparency permission needed for the current build? **No**

## Apple Health / HealthKit

- HealthKit capability required: **Yes**
- Access: **Read only**
- Health data requested by the current app:
  - body weight
  - height
  - body-fat percentage
  - waist circumference
  - resting heart rate
  - heart-rate variability (SDNN)
  - sleep analysis
- HealthKit writes: **None**
- HealthKit use for advertising/marketing/data mining: **None**
- HealthKit access required to use FitOS: **No**

The current purpose string is:

> FitOS reads selected Apple Health data to show body trends and recovery context for workout recommendations.

The current app uses every HealthKit type it requests. Recovery HealthKit values are contextual in 0.1 and do not silently rewrite a workout recommendation.

Before signing/archive, verify HealthKit is enabled for the App ID/provisioning profile and that the generated app entitlement contains `com.apple.developer.healthkit`.

Official references:
- `https://developer.apple.com/documentation/xcode/configuring-healthkit-access`
- `https://developer.apple.com/app-store/review/guidelines/`

## iCloud / backup handling

Apple’s Health/Fitness review rules state that apps using HealthKit may not store personal health information in iCloud.

FitOS 0.1 release policy and implementation:

- no CloudKit/iCloud health-data synchronization
- cloud accounts disabled
- FitOS does not automatically upload manual backup exports to iCloud
- beta UI tells users to save explicit backup exports locally, such as **On My iPhone**, rather than iCloud Drive
- all six FitOS local JSON persistence stores are marked `isExcludedFromBackup = true`, including the profile/body file that can contain HealthKit-imported measurements
- the CI release gate verifies that every local persistence store uses the protected write path and protects pre-existing files on upgrade

Official reference: `https://developer.apple.com/app-store/review/guidelines/`

## Regulated medical-device declaration

FitOS is positioned as a fitness/wellness and strength-training tool. It does not diagnose, treat, cure, prevent, or monitor disease as a medical device.

If App Store Connect asks whether the app is a regulated medical device for the EU/EEA, UK, or US, the expected 0.1 answer is **No**, assuming the submitted build and marketing copy remain within the current fitness/wellness scope.

Official reference: `https://developer.apple.com/help/app-store-connect/manage-app-information/declare-regulated-medical-device-status`

## Encryption / export compliance

Current repository configuration sets:

`ITSAppUsesNonExemptEncryption = NO`

FitOS currently uses system-provided networking/security such as HTTPS through `URLSession` and Keychain rather than proprietary encryption implemented by FitOS. Re-evaluate export-compliance answers if a later dependency introduces its own non-exempt cryptography.

Before upload, verify the archived build contains the expected `ITSAppUsesNonExemptEncryption` value.

## TestFlight beta information

Prepared copy lives in `docs/TESTFLIGHT_METADATA.md`.

For the first beta:

- no reviewer login/test account is required
- primary path: onboarding → Today → Build Today's Workout → Start Workout → mark sets DONE → Finish → return to Today
- Apple Health permission may be declined
- cloud account creation remains disabled
- Share AI Context and Share beta report are user initiated
- local backup export is user initiated and unencrypted

Paste the prepared Beta App Description, What to Test and reviewer notes from `docs/TESTFLIGHT_METADATA.md` rather than rewriting them in App Store Connect.

## App Store Connect actions that still require the account owner

- confirm active Apple Developer Program membership
- create/verify the App Store Connect app record and App ID
- enable HealthKit for the App ID and provisioning profile
- select the correct signing team in Xcode
- enter the Privacy Policy URL
- enter beta review contact name/email/phone where requested
- paste prepared TestFlight metadata
- answer App Privacy using the current-build guidance above
- complete regulated-medical-device declaration if App Store Connect presents it
- validate export-compliance state
- increment the build number if build `1` was previously uploaded
- Archive → Validate App → Upload in Xcode Organizer
- add internal testers
- complete the physical-device checklist in `docs/TESTFLIGHT_CHECKLIST.md`

## Hard re-review triggers

Do **not** reuse the “no data collected” answer without reassessment if any of these ship:

- FitOS cloud account creation or server backup
- remote built-in AI/LLM requests containing user context
- MCP/API access that sends user fitness data off-device
- third-party analytics or crash/telemetry SDK that retains app/user data
- advertising or attribution SDK
- subscriptions/payment SDK with additional data collection
- server-side push notification identifiers or profiles
- cloud nutrition/photo/voice processing
- any new SDK whose privacy manifest or documentation says it collects data

Update the public Privacy Policy and App Store privacy answers **before** releasing such a build.
