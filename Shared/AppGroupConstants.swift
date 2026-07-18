import Foundation

/// IMPORTANT SETUP STEP:
/// In Xcode, go to your Main App target -> Signing & Capabilities -> + Capability -> App Groups
/// Add a group named exactly: group.com.yourname.quranwidget
/// Repeat the SAME step for the Widget Extension target, using the SAME group id.
/// Then replace "com.yourname.quranwidget" below with your own bundle id prefix if you like.
enum AppGroup {
    static let id = "group.com.yourname.quranwidget"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }

    /// Shared container URL, used to store downloaded translation language files
    /// so both the app and the widget extension can read them.
    static var containerURL: URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: id)!
    }

    static var translationsFolder: URL {
        let url = containerURL.appendingPathComponent("Translations", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}

enum StorageKey {
    static let currentAyah = "currentAyah"
    static let refreshMinutes = "refreshMinutes"
    static let selectedThemeID = "selectedThemeID"
    static let selectedLanguageCode = "selectedLanguageCode"
    static let downloadedLanguages = "downloadedLanguages"
    static let lastRefreshDate = "lastRefreshDate"
}
