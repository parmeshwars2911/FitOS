import SwiftUI

struct CloudSettingsView: View {
    @EnvironmentObject private var appStore: AppStore
    @EnvironmentObject private var cloud: CloudAccountStore

    @State private var email = ""
    @State private var code = ""

    var body: some View {
        Form {
            if !cloud.isAvailable {
                Section("Cloud sync") {
                    Label("Not configured in this build", systemImage: "icloud.slash")
                    Text("Set FITOS_SUPABASE_URL and FITOS_SUPABASE_PUBLISHABLE_KEY in the Xcode build settings after provisioning a dedicated FitOS Supabase project.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else if let session = cloud.session {
                signedInSection(session)
            } else if let pendingEmail = cloud.pendingEmail {
                verificationSection(email: pendingEmail)
            } else {
                signInSection
            }

            if let message = cloud.statusMessage {
                Section("Status") {
                    Text(message)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Cloud & AI")
    }

    private var signInSection: some View {
        Section("FitOS account") {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()

            Button("Email me a sign-in code") {
                Task { await cloud.sendCode(email: email) }
            }
            .disabled(cloud.isBusy)

            Text("Sign-in tokens are stored in iOS Keychain. They are not stored in UserDefaults or committed with the app configuration.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func verificationSection(email: String) -> some View {
        Section("Verify \(email)") {
            TextField("Email code", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)

            Button("Verify and sign in") {
                Task { await cloud.verifyCode(code) }
            }
            .disabled(cloud.isBusy)

            Button("Use a different email", role: .cancel) {
                cloud.cancelCodeEntry()
                code = ""
            }
            .disabled(cloud.isBusy)
        }
    }

    @ViewBuilder
    private func signedInSection(_ session: SupabaseAuthSession) -> some View {
        Section("FitOS account") {
            LabeledContent("User", value: shortUserID(session.userID))
            if let metadata = cloud.syncMetadata {
                LabeledContent("Cloud revision", value: String(metadata.revision))
                LabeledContent("Last backup") {
                    Text(metadata.lastSyncedAt, style: .relative)
                }
            } else {
                Text("No cloud backup has been recorded on this device yet.")
                    .foregroundStyle(.secondary)
            }

            Button {
                Task { await cloud.sync(appStore: appStore) }
            } label: {
                if cloud.isBusy {
                    HStack {
                        ProgressView()
                        Text("Syncing…")
                    }
                } else {
                    Label("Back up to cloud", systemImage: "icloud.and.arrow.up")
                }
            }
            .disabled(cloud.isBusy)
        }

        Section {
            Button("Sign out", role: .destructive) {
                Task { await cloud.signOut() }
            }
            .disabled(cloud.isBusy)
        } footer: {
            Text("Cloud backup does not grant ChatGPT, Claude, or any MCP client access. External AI sharing will require a separate opt-in permission.")
        }
    }

    private func shortUserID(_ id: UUID) -> String {
        String(id.uuidString.prefix(8)).uppercased()
    }
}
