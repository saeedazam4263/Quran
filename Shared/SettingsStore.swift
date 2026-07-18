import Foundation
import WidgetKit

/// Single source of truth for user settings. Both the main app and the
/// widget extension read/write through this so they always agree.
final class SettingsStore {
    static let shared = SettingsStore()
    private let defaults = AppGroup.sharedDefaults

    private init() {}

    /// Custom refresh interval, in minutes. User can type any value (min 15,
    /// since iOS budgets Lock Screen widget refreshes and won't honor
    /// anything drastically more frequent).
    var refreshMinutes: Int {
        get {
            let value = defaults.integer(forKey: StorageKey.refreshMinutes)
            return value == 0 ? 60 : value // default: hourly
        }
        set {
            let clamped = max(15, newValue) // iOS floor for reliable refreshes
            defaults.set(clamped, forKey: StorageKey.refreshMinutes)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    var selectedTheme: WidgetTheme {
        get {
            guard let raw = defaults.string(forKey: StorageKey.selectedThemeID),
                  let theme = WidgetTheme(rawValue: raw) else { return .classic }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: StorageKey.selectedThemeID)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    var selectedLanguage: QuranLanguage {
        get {
            guard let code = defaults.string(forKey: StorageKey.selectedLanguageCode),
                  let lang = SupportedLanguages.all.first(where: { $0.code == code }) else {
                return SupportedLanguages.bundledDefault
            }
            return lang
        }
        set {
            defaults.set(newValue.code, forKey: StorageKey.selectedLanguageCode)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    var downloadedLanguageCodes: Set<String> {
        get {
            let arr = defaults.stringArray(forKey: StorageKey.downloadedLanguages) ?? [SupportedLanguages.bundledDefault.code]
            return Set(arr)
        }
        set {
            defaults.set(Array(newValue), forKey: StorageKey.downloadedLanguages)
        }
    }

    /// The current ayah is cached here so the widget can render instantly
    /// even before its own timeline provider re-fetches.
    func saveCurrentAyah(_ ayah: Ayah) {
        if let data = try? JSONEncoder().encode(ayah) {
            defaults.set(data, forKey: StorageKey.currentAyah)
        }
        defaults.set(Date(), forKey: StorageKey.lastRefreshDate)
    }

    func loadCurrentAyah() -> Ayah? {
        guard let data = defaults.data(forKey: StorageKey.currentAyah) else { return nil }
        return try? JSONDecoder().decode(Ayah.self, from: data)
    }
}
