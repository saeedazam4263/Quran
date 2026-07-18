import Foundation

/// Talks to the free AlQuran Cloud API (https://alquran.cloud/api).
/// No API key required. Swap this out for a different provider if you prefer.
final class QuranAPIService {
    static let shared = QuranAPIService()
    private init() {}

    private let baseURL = "https://api.alquran.cloud/v1"

    enum ServiceError: Error {
        case badResponse
        case decodingFailed
    }

    /// Fetches a random ayah with Arabic text + the requested translation.
    /// The Quran has 6236 ayahs total (by the standard numbering used by this API).
    func fetchRandomAyah(language: QuranLanguage) async throws -> Ayah {
        let randomNumber = Int.random(in: 1...6236)
        return try await fetchAyah(number: randomNumber, language: language)
    }

    /// Fetches a specific ayah (1-6236 global numbering) with Arabic + translation.
    func fetchAyah(number: Int, language: QuranLanguage) async throws -> Ayah {
        // The "editions" endpoint lets us fetch Arabic + translation in one call.
        let editions = "quran-uthmani,\(language.editionIdentifier)"
        guard let url = URL(string: "\(baseURL)/ayah/\(number)/editions/\(editions)") else {
            throw ServiceError.badResponse
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ServiceError.badResponse
        }
        let decoded = try JSONDecoder().decode(EditionsResponse.self, from: data)
        guard decoded.data.count == 2 else { throw ServiceError.decodingFailed }

        let arabic = decoded.data[0]
        let translation = decoded.data[1]

        return Ayah(
            surahNumber: arabic.surah.number,
            surahNameArabic: arabic.surah.name,
            surahNameEnglish: arabic.surah.englishName,
            ayahNumber: arabic.numberInSurah,
            arabicText: arabic.text,
            translationText: translation.text,
            languageCode: language.code
        )
    }
}

// MARK: - API response models

private struct EditionsResponse: Codable {
    let data: [AyahEditionData]
}

private struct AyahEditionData: Codable {
    let number: Int
    let text: String
    let numberInSurah: Int
    let surah: SurahInfo
}

private struct SurahInfo: Codable {
    let number: Int
    let name: String
    let englishName: String
}
