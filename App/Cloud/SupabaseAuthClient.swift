import Foundation

struct SupabaseAuthSession: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let userID: UUID

    var needsRefresh: Bool {
        expiresAt.timeIntervalSinceNow < 120
    }
}

enum SupabaseAuthError: LocalizedError {
    case invalidResponse
    case server(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "FitOS could not read the cloud sign-in response."
        case let .server(statusCode, message):
            return "FitOS sign-in error \(statusCode): \(message)"
        }
    }
}

struct SupabaseAuthClient {
    private let configuration: SupabaseConfiguration
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder: JSONDecoder

    init(configuration: SupabaseConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func requestEmailOTP(email: String) async throws {
        let request = try makeRequest(
            url: authURL(path: "otp"),
            body: OTPRequest(email: email, createUser: true)
        )
        _ = try await perform(request)
    }

    func verifyEmailOTP(email: String, token: String) async throws -> SupabaseAuthSession {
        let request = try makeRequest(
            url: authURL(path: "verify"),
            body: VerifyRequest(type: "email", email: email, token: token)
        )
        let data = try await perform(request)
        return try decodeSession(from: data)
    }

    func refresh(refreshToken: String) async throws -> SupabaseAuthSession {
        var components = URLComponents(url: authURL(path: "token"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token")]
        guard let url = components?.url else { throw SupabaseAuthError.invalidResponse }

        let request = try makeRequest(url: url, body: RefreshRequest(refreshToken: refreshToken))
        let data = try await perform(request)
        return try decodeSession(from: data)
    }

    func signOut(accessToken: String) async throws {
        var request = URLRequest(url: authURL(path: "logout"))
        request.httpMethod = "POST"
        request.setValue(configuration.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = try await perform(request)
    }

    private func decodeSession(from data: Data) throws -> SupabaseAuthSession {
        let response = try decoder.decode(TokenResponse.self, from: data)
        guard let userID = UUID(uuidString: response.user.id) else {
            throw SupabaseAuthError.invalidResponse
        }
        return SupabaseAuthSession(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: Date().addingTimeInterval(TimeInterval(response.expiresIn)),
            userID: userID
        )
    }

    private func authURL(path: String) -> URL {
        configuration.apiURL
            .appendingPathComponent("auth")
            .appendingPathComponent("v1")
            .appendingPathComponent(path)
    }

    private func makeRequest<Body: Encodable>(url: URL, body: Body) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(configuration.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return request
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseAuthError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw SupabaseAuthError.server(statusCode: http.statusCode, message: message)
        }
        return data
    }
}

private struct OTPRequest: Encodable {
    let email: String
    let createUser: Bool

    enum CodingKeys: String, CodingKey {
        case email
        case createUser = "create_user"
    }
}

private struct VerifyRequest: Encodable {
    let type: String
    let email: String
    let token: String
}

private struct RefreshRequest: Encodable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

private struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: AuthUser
}

private struct AuthUser: Decodable {
    let id: String
}
