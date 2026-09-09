import Foundation

extension SupabaseConfiguration {
    static func fromBundle(_ bundle: Bundle = .main) -> SupabaseConfiguration? {
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
}
