# FitOS cloud deployment

This guide turns the checked-in FitOS cloud code into a live backend. The app is intentionally safe when these steps have not been completed: cloud controls remain unavailable and all core fitness features continue to work locally.

## Architecture

FitOS V1 cloud sync uses:

- a **dedicated Supabase project** for authentication and storage
- email one-time-code sign-in
- iOS Keychain for access/refresh tokens
- one versioned `CloudStateSnapshot` per authenticated user
- PostgreSQL Row Level Security (RLS) so users can access only their own snapshot
- an optimistic integer revision so a stale device cannot silently overwrite newer cloud state
- explicit restore confirmation when a device discovers an unknown cloud revision

Cloud backup and external AI access are separate permissions. Enabling cloud sync does **not** grant ChatGPT, Claude, or an MCP client access.

## 1. Create a dedicated FitOS Supabase project

Do not reuse another application's production database. Create a project specifically for FitOS, ideally in a region close to the initial users.

Record only these client-safe values for the iOS build:

- Project API URL, such as `https://<project-ref>.supabase.co`
- a modern **publishable key** (`sb_publishable_...`)

Never place a `service_role` key, secret key, database password, or JWT signing secret in the iOS app, source repository, Xcode project, or MCP client.

## 2. Apply the checked-in migration

Apply:

```text
supabase/migrations/20260909121000_fitos_cloud_state.sql
```

The migration creates:

- `public.fitos_cloud_state`
- a 5 MB JSON payload guard
- forced RLS
- authenticated-user-only SELECT/INSERT/UPDATE policies
- `fitos_pull_state()`
- `fitos_commit_state(p_expected_revision, p_payload)`
- optimistic revision conflict handling

Using the Supabase CLI, a typical flow is:

```bash
supabase login
supabase link --project-ref <FITOS_PROJECT_REF>
supabase db push
```

Alternatively, apply the migration through the Supabase SQL editor after reviewing it.

## 3. Configure email OTP authentication

FitOS asks the user for an emailed numeric/code token and verifies it through Supabase Auth.

In **Authentication → Email Templates**, configure the sign-in email to display the token rather than relying only on a magic-link URL. The template must include Supabase's token variable:

```text
{{ .Token }}
```

A minimal body can be:

```html
<h2>Your FitOS sign-in code</h2>
<p>Enter this code in FitOS:</p>
<p><strong>{{ .Token }}</strong></p>
```

Keep email authentication enabled. Before production, also configure an appropriate SMTP provider, sender identity, rate limits, and redirect/site settings in Supabase Auth.

Current Supabase references:

- Passwordless email auth: https://supabase.com/docs/guides/auth/auth-email-passwordless
- Email templates: https://supabase.com/docs/guides/auth/auth-email-templates

## 4. Configure the iOS build

`project.yml` contains intentionally empty defaults:

```yaml
FITOS_SUPABASE_URL: ""
FITOS_SUPABASE_PUBLISHABLE_KEY: ""
```

For a local or CI build that should use cloud sync, supply:

```text
FITOS_SUPABASE_URL = https://<project-ref>.supabase.co
FITOS_SUPABASE_PUBLISHABLE_KEY = sb_publishable_...
```

These values are injected into generated Info.plist keys and read by `SupabaseConfiguration.fromBundle()`.

A publishable key is safe to ship in a client but **does not authorize access by itself**. The user's Supabase access token plus RLS is the authorization boundary.

For production, prefer an uncommitted `.xcconfig` or CI secret-to-build-setting pipeline rather than editing the checked-in defaults.

## 5. Regenerate and build

```bash
brew install xcodegen
xcodegen generate
open FitOS.xcodeproj
```

The app should now show the account controls under:

```text
Settings → Cloud & AI
```

## 6. Run the security checks

After the migration is live, verify all of the following:

- RLS is enabled and forced on `public.fitos_cloud_state`.
- `anon` cannot read/write the table or execute the FitOS RPCs.
- an authenticated user can read only the row where `user_id = auth.uid()`.
- user A cannot fetch or overwrite user B's row.
- `fitos_commit_state` rejects an incorrect `p_expected_revision` with `revision_conflict`.
- no service-role or secret key is present in the iOS binary/configuration.
- Supabase Security Advisor has no unresolved issue related to the FitOS objects.

Do not weaken RLS to make an integration test pass.

## 7. Acceptance-test the cloud lifecycle

Use a test account and exercise these cases in order.

### A. Sign in

1. Open **Settings → Cloud & AI**.
2. Enter an email.
3. Confirm the email contains a code.
4. Enter the code in FitOS.
5. Verify the session survives an app relaunch through Keychain storage.

### B. First backup

1. Log at least one workout or nutrition entry.
2. Tap **Back up to cloud**.
3. Verify revision `1` is created.

### C. Subsequent backup

1. Change local FitOS data.
2. Back up again.
3. Verify the revision increases and the cloud snapshot changes.

### D. Stale/second-device protection

1. Advance the cloud revision from device A.
2. Use device B with an older last-known revision.
3. Attempt backup on device B.
4. Verify FitOS refuses to overwrite the remote row and presents the cloud snapshot as pending.

### E. Explicit restore

1. Review the pending revision and record counts.
2. Choose **Restore this device from cloud**.
3. Confirm the destructive dialog.
4. Verify local workouts, body records, training targets and nutrition now match the remote snapshot.
5. Verify Apple Health authorization itself was not changed.

## 8. Failure behavior to preserve

FitOS deliberately fails closed:

- unknown `CloudStateSnapshot.schemaVersion` → reject the payload
- stale revision → do not overwrite
- unknown existing cloud revision → present restore, do not auto-apply
- no backend configuration → remain local-only
- expired access token → refresh using the rotated refresh token and replace the Keychain session

Do not replace these behaviors with last-write-wins sync until the domain records have a deliberate merge model.

## 9. MCP comes after cloud activation

The V1 MCP boundary is documented in `docs/MCP_CONTRACT.md`.

The first external AI tool should remain read-only and expose the deterministic FitOS context, conceptually:

```text
fitos_get_coach_context
```

It should return `CoachContext` + `WeeklyReview` for the authenticated user rather than unrestricted SQL/database access.

Cloud sync alone must never imply consent to MCP/AI sharing. External AI access needs a separate, revocable opt-in authorization layer.

## 10. Production readiness still required

Before public/TestFlight production use, add or verify:

- dedicated production Supabase project and separate non-production environment
- custom SMTP and abuse/rate-limit configuration
- monitoring/alerting for Auth and RPC failures
- backup/recovery policy for the database
- privacy policy and account/data-deletion flow
- explicit AI/MCP consent and revocation if MCP is deployed
- real-device sign-in, backup and restore testing

The cloud architecture is intentionally small in V1. Preserve the versioned snapshot and revision boundary until there is evidence that record-level multi-device merging is necessary.
