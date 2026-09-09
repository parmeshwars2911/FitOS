import Foundation

struct SupabaseConfiguration: Sendable, Equatable {
    let apiURL: URL
    let publishableKey: String

    init(apiURL: URL, publishableKey: String) {
        self.apiURL = apiURL
        self.publishableKey = publishableKey
    }
}

enum SupabaseSyncError: LocalizedError {
    case invalidResponse
    case unauthorized
    case revisionConflict
    case server(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "FitOS cloud returned an invalid response."
        case .unauthorized:
            return "Your FitOS cloud session is no longer authorized."
        case .revisionConflict:
            return "FitOS cloud has a newer revision. Pull before trying to upload again."
        case let .server(statusCode, message):
            return "FitOS cloud error \(statusCode): \(message)"
        }
    }
}

struct SupabaseSyncClient {
    private let configuration: SupabaseConfiguration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(configuration: SupabaseConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func pull(accessToken: String) async throws -> RemoteCloudState? {
        let data = try await callRPC(
            name: "fitos_pull_state",
            accessToken: accessToken,
            body: EmptyRequest()
        )

        if data == Data("null".utf8) || data.isEmpty {
            return nil
        }

        let state = try decoder.decode(RemoteCloudState.self, from: data)
        try state.payload.validate()
        return state
    }

    func commit(
        snapshot: CloudStateSnapshot,
        expectedRevision: Int64?,
        accessToken: String
    ) async throws -> RemoteCloudState {
        try snapshot.validate()
        let data = try await callRPC(
            name: "fitos_commit_state",
            accessToken: accessToken,
            body: CommitRequest(pExpectedRevision: expectedRevision, pPayload: snapshot)
        )
        let state = try decoder.decode(RemoteCloudState.self, from: data)
        try state.payload.validate()
        return state
    }

    private func callRPC<Body: Encodable>(
        name: String,
        accessToken: String,
        body: Body
    ) async throws -> Data {
        let url = configuration.apiURL
            .appendingPathComponent("rest")
            .appendingPathComponent("v1")
            .appendingPathComponent("rpc")
            .appendingPathComponent(name)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(configuration.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseSyncError.invalidResponse
        }

        if http.statusCode == 401 || http.statusCode == 403 {
            throw SupabaseSyncError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            if message.localizedCaseInsensitiveContains("revision_conflict") {
                throw SupabaseSyncError.revisionConflict
            }
            throw SupabaseSyncError.server(statusCode: http.statusCode, message: message)
        }

        return data
    }
}

private struct EmptyRequest: Encodable {}

private struct CommitRequest: Encodable {
    let pExpectedRevision: Int64?
    let pPayload: CloudStateSnapshot

    enum CodingKeys: String, CodingKey {
        case pExpectedRevision = "p_expected_revision"
        case pPayload = "p_payload"
    }
}
