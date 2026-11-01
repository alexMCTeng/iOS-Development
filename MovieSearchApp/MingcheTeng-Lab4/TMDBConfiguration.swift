import Foundation

enum TMDBConfiguration {
    /// Populated from a local xcconfig during the build, never from a Swift literal.
    /// This keeps credentials out of Git; the built app's plist is still readable.
    static var apiKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "TMDBAPIKey") as? String else {
            return nil
        }
        let key = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !key.contains("$(") else { return nil }
        return key
    }
}
