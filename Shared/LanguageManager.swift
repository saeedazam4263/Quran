import Foundation
import Combine

/// Downloads a full translation edition (all 6236 ayahs) once, and caches it
/// as JSON in the shared App Group container so the widget extension can
/// pick random verses OFFLINE without making network calls of its own
/// (Lock Screen widgets have very limited/unreliable network access, so
/// pre-downloading is the reliable approach).
@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var downloadProgress: [String: Double] = [:]   // languageCode -> 0...1
    @Published var downloadedCodes: Set<String> = SettingsStore.shared.downloadedLanguageCodes

    private init() {}

    private func fileURL(for language: QuranLanguage) -> URL {
        AppGroup.translationsFolder.appendingPathComponent("\(language.code).json")
    }

    func isDownloaded(_ language: QuranLanguage) -> Bool {
        language.code == SupportedLanguages.bundledDefault.code
            || FileManager.default.fileExists(atPath: fileURL(for: language).path)
    }

    /// Downloads the entire edition (Arabic + translation) for a language,
    /// so the widget can later pick any random ayah from local storage.
    func download(_ language: QuranLanguage) async throws {
        downloadProgress[language.code] = 0.01

        guard let url = URL(string: "https://api.alquran.cloud/v1/quran/\(language.editionIdentifier)") else {
            throw QuranAPIService.ServiceError.badResponse
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw QuranAPIService.ServiceError.badResponse
        }

        downloadProgress[language.code] = 0.7

        // Re-save as our own compact Ayah array so lookups are fast later.
        let parsed = try JSONDecoder().decode(FullEditionResponse.self, from: data)
        let ayahs: [Ayah] = parsed.data.surahs.flatMap { surah in
            surah.ayahs.map { ayah in
                Ayah(
                    surahNumber: surah.number,
                    surahNameArabic: surah.name,
                    surahNameEnglish: surah.englishName,
                    ayahNumber: ayah.numberInSurah,
                    arabicText: "", // filled in from the Arabic edition separately if desired
                    translationText: ayah.text,
                    languageCode: language.code
                )
            }
        }

        let outData = try JSONEncoder().encode(ayahs)
        try outData.write(to: fileURL(for: language), options: .atomic)

        downloadProgress[language.code] = 1.0
        downloadedCodes.insert(language.code)
        SettingsStore.shared.downloadedLanguageCodes = downloadedCodes
    }

    func delete(_ language: QuranLanguage) {
        try? FileManager.default.removeItem(at: fileURL(for: language))
        downloadedCodes.remove(language.code)
        SettingsStore.shared.downloadedLanguageCodes = downloadedCodes
    }

    /// Reads a random cached ayah for offline use (used as a widget fallback
    /// when the network is unavailable).
    func randomCachedAyah(for language: QuranLanguage) -> Ayah? {
        guard let data = try? Data(contentsOf: fileURL(for: language)),
              let ayahs = try? JSONDecoder().decode([Ayah].self, from: data),
              let pick = ayahs.randomElement() else { return nil }
        return pick
    }
}

// MARK: - Full edition response models

private struct FullEditionResponse: Codable {
    let data: FullEditionData
}
private struct FullEditionData: Codable {
    let surahs: [FullSurah]
}
private struct FullSurah: Codable {
    let number: Int
    let name: String
    let englishName: String
    let ayahs: [FullAyah]
}
private struct FullAyah: Codable {
    let numberInSurah: Int
    let text: String
}
