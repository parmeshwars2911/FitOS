import Combine
import Foundation

final class CloudAccountStore: ObservableObject {
    @Published private(set) var session: SupabaseAuthSession?
    @Published private(set) var pendingEmail: String?
    @Published private(set) var isBusy = false
    @Published private(set) var statusMessage: String?
    @Published private(set) var syncMetadata: CloudSyncMetadata?

    let configuration: SupabaseConfiguration?

    private let keychain: CloudSessionKeychain
    private let metadataStore: CloudSyncMetadataStore

    init(
        configuration: SupabaseConfiguration? = .fromBundle(),
        keychain: CloudSessionKeychain = CloudSessionKeychain(),
        metadataStore: CloudSyncMetadataStore = CloudSyncMetadataStore()
    ) {
        self.configuration = configuration
        self.keychain = keychain
        self.metadataStore = metadataStore
        let storedSession = keychain.load()
        self.session = storedSession
        if let storedSession {
            self.syncMetadata = metadataStore.load(userID: storedSession.userID)
        }
    }

    var isAvailable: Bool { configuration != nil }
    var isSignedIn: Bool { session != nil }

    @MainActor
    func sendCode(email: String) async {
        guard let configuration else {
            statusMessage = "Cloud sync is not configured in this build."
            return
        }
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanEmail.contains("@") else {
            statusMessage = "Enter a valid email address."
            return
        }

        isBusy = true
        statusMessage = nil
        defer { isBusy = false }

        do {
            try await SupabaseAuthClient(configuration: configuration).requestEmailOTP(email: cleanEmail)
            pendingEmail = cleanEmail
            statusMessage = "A sign-in code was sent to your email."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    @MainActor
    func verifyCode(_ code: String) async {
        guard let configuration, let pendingEmail else { return }
        let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanCode.isEmpty else {
            statusMessage = "Enter the code from your email."
            return
        }

        isBusy = true
        statusMessage = nil
        defer { isBusy = false }

        do {
            let verified = try await SupabaseAuthClient(configuration: configuration)
                .verifyEmailOTP(email: pendingEmail, token: cleanCode)
            try keychain.save(verified)
            session = verified
            syncMetadata = metadataStore.load(userID: verified.userID)
            self.pendingEmail = nil
            statusMessage = "Signed in."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    @MainActor
    func cancelCodeEntry() {
        pendingEmail = nil
        statusMessage = nil
    }

    @MainActor
    func signOut() async {
        let current = session
        if let configuration, let current {
            try? await SupabaseAuthClient(configuration: configuration).signOut(accessToken: current.accessToken)
        }
        keychain.clear()
        session = nil
        pendingEmail = nil
        syncMetadata = nil
        statusMessage = "Signed out on this device."
    }

    @MainActor
    func sync(appStore: AppStore) async {
        guard let configuration, let current = session else {
            statusMessage = "Sign in before syncing."
            return
        }

        isBusy = true
        statusMessage = nil
        defer { isBusy = false }

        do {
            let validSession = try await refreshIfNeeded(current, configuration: configuration)
            let client = SupabaseSyncClient(configuration: configuration)
            let remote = try await client.pull(accessToken: validSession.accessToken)
            let known = metadataStore.load(userID: validSession.userID)

            if let remote {
                guard let known, known.revision == remote.revision else {
                    syncMetadata = CloudSyncMetadata(
                        revision: remote.revision,
                        lastSyncedAt: remote.updatedAt
                    )
                    statusMessage = "Cloud has an unrecognized newer revision. FitOS did not overwrite it. Restore/reconciliation will be added before multi-device sync is enabled."
                    return
                }

                let committed = try await client.commit(
                    snapshot: appStore.makeCloudSnapshot(),
                    expectedRevision: remote.revision,
                    accessToken: validSession.accessToken
                )
                record(committed, userID: validSession.userID)
                statusMessage = "Cloud backup updated."
            } else {
                let committed = try await client.commit(
                    snapshot: appStore.makeCloudSnapshot(),
                    expectedRevision: nil,
                    accessToken: validSession.accessToken
                )
                record(committed, userID: validSession.userID)
                statusMessage = "First cloud backup created."
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    @MainActor
    private func refreshIfNeeded(
        _ current: SupabaseAuthSession,
        configuration: SupabaseConfiguration
    ) async throws -> SupabaseAuthSession {
        guard current.needsRefresh else { return current }
        let refreshed = try await SupabaseAuthClient(configuration: configuration)
            .refresh(refreshToken: current.refreshToken)
        try keychain.save(refreshed)
        session = refreshed
        return refreshed
    }

    @MainActor
    private func record(_ remote: RemoteCloudState, userID: UUID) {
        let metadata = CloudSyncMetadata(
            revision: remote.revision,
            lastSyncedAt: remote.updatedAt
        )
        metadataStore.save(metadata, userID: userID)
        syncMetadata = metadata
    }
}
