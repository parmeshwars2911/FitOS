# FitOS Privacy Policy

**Effective date:** September 10, 2026

FitOS is a fitness tracking and adaptive workout application for iPhone. This Privacy Policy explains what information FitOS handles in the 0.1 beta, where that information is stored, and what choices you have.

## 1. Information you choose to enter

FitOS can store information you enter while using the app, including:

- workout history, exercises, sets, repetitions, load and reps-in-reserve (RIR)
- exercise preferences and training targets
- body measurements such as weight, waist, chest, arm, thigh and optional body-fat percentage
- nutrition entries and calorie/protein/carbohydrate/fat targets
- generated-workout acceptance information, such as whether you accepted, replaced or skipped a recommended exercise
- optional 1–5 usefulness ratings and feedback about FitOS-generated workouts

For the FitOS 0.1 beta, this information is stored locally in the app's iOS storage on your device unless you explicitly export or share it using one of the features described below.

## 2. Apple Health

FitOS can optionally request read-only access to selected Apple Health data that is relevant to fitness tracking and recovery context. Depending on the permissions you grant, this can include:

- body weight
- height
- body-fat percentage
- waist circumference
- sleep information
- resting heart rate
- heart-rate variability (HRV)

Apple Health access is optional. You can use FitOS without granting Health access.

FitOS does not write data to Apple Health in the 0.1 beta. It does not use Health data for advertising, marketing profiles, or data brokerage. FitOS may keep local copies of supported Health measurements it imports so that it can calculate body trends. Health authorization can be changed through Apple's Health/privacy controls.

FitOS currently displays sleep, resting-heart-rate and HRV information as context only. The 0.1 beta does not silently change a workout because of a single Health reading.

## 3. Adaptive fitness calculations

FitOS calculates training state, training debt, recovery estimates, progression guidance, body trends, nutrition summaries, and weekly coaching context using deterministic software in the app.

These calculations use your logged or imported fitness data to provide the app's core functionality. They are fitness guidance, not medical diagnosis or treatment.

## 4. AI context sharing

FitOS includes an explicit **Share AI Context** action. FitOS does not automatically send your fitness history to ChatGPT, Claude, Gemini, or another AI service in the 0.1 beta.

When you choose Share AI Context, FitOS prepares a structured summary and opens the iOS share sheet. Nothing is sent until you choose a destination. If you share information with another application or service, that destination receives the information you selected and its own privacy policy applies to its handling of that information.

## 5. Local backup export and import

FitOS lets you explicitly export a versioned local backup file. A backup can include FitOS-managed information such as:

- workouts
- body measurements, including supported measurements previously imported from Apple Health
- training targets
- nutrition entries and targets
- exercise preferences
- generated-plan adherence records
- workout usefulness ratings

**FitOS backup files are plain JSON and are not encrypted by FitOS.** Treat exported backups as sensitive fitness information. The privacy and security of a backup after export depend on where you save, copy, upload, or share that file.

FitOS does not include Keychain credentials, cloud authentication tokens, backend secrets, or Apple Health authorization state in a local backup.

Importing a backup requires validation and an explicit confirmation before FitOS replaces local app data.

## 6. Cloud accounts and cloud backup

Cloud account creation is **disabled in the FitOS 0.1 beta release configuration**. The app may contain development code for a future FitOS cloud service, but that code is not activated in the first beta build.

FitOS will update this Privacy Policy and complete the required account-deletion and backend privacy/security work before enabling account creation or cloud backup in a public release.

## 7. Analytics, beta-report sharing, advertising, and sale of data

The FitOS 0.1 beta does not include a third-party analytics SDK or advertising SDK.

FitOS does not sell your personal information or fitness/health information to advertisers or data brokers.

The beta's recommendation-usefulness and generated-exercise-acceptance metrics are calculated from FitOS data on your device. They are not automatically uploaded to FitOS or to an analytics provider in this release.

FitOS includes an explicit **Share beta report** action. If you choose it, FitOS prepares aggregate beta metrics and opens the iOS share sheet. The report can include the FitOS app/build version, counts of completed/generated workouts and planned/accepted/replaced/skipped recommended exercises, aggregate acceptance/usefulness rates, and totals for optional feedback-reason categories.

The aggregate beta report does **not** include individual workout or exercise identifiers, set/load/repetition values, body measurements, nutrition values, Apple Health values, account details, or device identifiers. Nothing is transmitted until you choose a destination in the system share sheet. The destination you choose then handles the report under its own privacy policy.

## 8. Data retention and deletion

FitOS local data remains on the device until it is removed through available app controls or the FitOS app is deleted from the device, subject to normal iOS/device backup behavior outside FitOS's control.

Deleting FitOS does not delete the original records stored in Apple Health because FitOS has read-only Health access. You can manage Apple Health records and FitOS's Health permissions through Apple's controls.

Files you previously exported from FitOS are outside the app's storage. Removing the app does not delete copies you saved to Files, iCloud Drive, another storage provider, or another application. You must delete those copies from the location where you stored them if you no longer want to keep them.

## 9. Security

FitOS is designed to keep the first beta local-first and to minimize unnecessary data transmission. Local app data is protected by the security controls provided by iOS and the device.

No method of storage is completely risk-free. In particular, user-exported FitOS JSON backups are intentionally portable and are not encrypted by FitOS. Store exported files appropriately.

## 10. Medical and wellness information

FitOS is a fitness and wellness tool. It is not a medical device and is not intended to diagnose, treat, cure, or prevent a disease or medical condition. Workout, recovery, nutrition, and body-composition information should not be treated as medical advice.

## 11. Changes to this policy

FitOS may update this Privacy Policy as the product changes. Material changes to data collection or transmission—such as enabling FitOS cloud accounts, remote AI processing, analytics, or other third-party services—will be reflected in an updated policy before those features are released.

## 12. Contact

For questions or privacy requests related to the beta, use the FitOS GitHub repository issue tracker:

https://github.com/parmeshwars2911/FitOS/issues

Before a broad public App Store launch, FitOS may replace or supplement this developer contact with a dedicated production support/privacy contact.
