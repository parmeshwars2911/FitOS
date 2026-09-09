import Foundation
import Security

enum CloudSessionKeychainError: LocalizedError {
    case encode
    case store(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encode:
            return "FitOS could not securely encode the cloud session."
        case let .store(status):
            return "FitOS could not store the cloud session in Keychain (\(status))."
        }
    }
}

struct CloudSessionKeychain {
    private let service: String
    private let account = "supabase-auth-session"

    init(service: String = Bundle.main.bundleIdentifier ?? "com.parmeshwars2911.FitOS") {
        self.service = service
    }

    func load() -> SupabaseAuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(SupabaseAuthSession.self, from: data)
    }

    func save(_ session: SupabaseAuthSession) throws {
        guard let data = try? JSONEncoder().encode(session) else {
            throw CloudSessionKeychainError.encode
        }

        SecItemDelete(baseQuery as CFDictionary)
        var item = baseQuery
        item[kSecValueData as String] = data
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw CloudSessionKeychainError.store(status)
        }
    }

    func clear() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
