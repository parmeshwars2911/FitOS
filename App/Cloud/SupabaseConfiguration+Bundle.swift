import Foundation

extension SupabaseConfiguration {
    static func fromBundle(_ bundle: Bundle = .main) -> SupabaseConfiguration? {
        guard cloudAccountsEnabled(in: bundle) else { return nil }

        guard
            let urlString = bundle.object(forInfoDictionaryKey: "FITOS_SUPABASE_URL") as? String,
            let key = bundle.object(forInfoDictionaryKey: "FITOS_SUPABASE_PUBLISHABLE_KEY") as? String,
            !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !urlString.contains("$("),
            !key.contains("$("),
            let url = URL(string: urlString)
        else {
            return nil
        }

        return SupabaseConfiguration(apiURL: url, publishableKey: key)
    }

    private static func cloudAccountsEnabled(in bundle: Bundle) -> Bool {
        if let value = bundle.object(forInfoDictionaryKey: "FITOS_CLOUD_ACCOUNTS_ENABLED") as? Bool {
            return value
        }
        guard let raw = bundle.object(forInfoDictionaryKey: "FITOS_CLOUD_ACCOUNTS_ENABLED") as? String else {
            return false
        }
        return ["yes", "true", "1"].contains(raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
    }
}
