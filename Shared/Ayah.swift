import Foundation

/// A single Quran verse with its translation, ready to display.
struct Ayah: Codable, Identifiable, Equatable {
    var id: String { "\(surahNumber):\(ayahNumber)" }
    let surahNumber: Int
    let surahNameArabic: String
    let surahNameEnglish: String
    let ayahNumber: Int
    let arabicText: String
    let translationText: String
    let languageCode: String   // e.g. "en", "ur", "fr"

    static let placeholder = Ayah(
        surahNumber: 1,
        surahNameArabic: "الفاتحة",
        surahNameEnglish: "Al-Fatihah",
        ayahNumber: 1,
        arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        translationText: "In the name of Allah, the Most Gracious, the Most Merciful.",
        languageCode: "en"
    )

    init(surahNumber: Int, surahNameArabic: String, surahNameEnglish: String, ayahNumber: Int, arabicText: String, translationText: String, languageCode: String) {
        self.surahNumber = surahNumber
        self.surahNameArabic = surahNameArabic
        self.surahNameEnglish = surahNameEnglish
        self.ayahNumber = ayahNumber
        self.arabicText = arabicText
        self.translationText = translationText
        self.languageCode = languageCode
    }
}

/// A downloadable translation language.
struct QuranLanguage: Codable, Identifiable, Equatable, Hashable {
    var id: String { code }
    let code: String        // ISO-ish code used by the API, e.g. "en", "ur", "fr", "id"
    let displayName: String // "English", "Urdu", "French", "Indonesian"
    let editionIdentifier: String // API edition identifier, e.g. "en.sahih"
}

/// Built-in list of languages the user can download. English ships bundled;
/// everything else is fetched on demand and cached in the App Group container.
enum SupportedLanguages {
    static let all: [QuranLanguage] = [
        QuranLanguage(code: "en", displayName: "English", editionIdentifier: "en.sahih"),
        QuranLanguage(code: "ur", displayName: "Urdu", editionIdentifier: "ur.jalandhry"),
        QuranLanguage(code: "fr", displayName: "French", editionIdentifier: "fr.hamidullah"),
        QuranLanguage(code: "es", displayName: "Spanish", editionIdentifier: "es.cortes"),
        QuranLanguage(code: "id", displayName: "Indonesian", editionIdentifier: "id.indonesian"),
        QuranLanguage(code: "tr", displayName: "Turkish", editionIdentifier: "tr.diyanet"),
        QuranLanguage(code: "de", displayName: "German", editionIdentifier: "de.bubenheim"),
        QuranLanguage(code: "bn", displayName: "Bengali", editionIdentifier: "bn.bengali"),
        QuranLanguage(code: "ru", displayName: "Russian", editionIdentifier: "ru.kuliev"),
        QuranLanguage(code: "ms", displayName: "Malay", editionIdentifier: "ms.basmeih")
    ]

    static let bundledDefault = all[0] // English
}
