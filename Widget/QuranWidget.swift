import WidgetKit
import SwiftUI

struct AyahEntry: TimelineEntry {
    let date: Date
    let ayah: Ayah
    let theme: WidgetTheme
}

struct QuranWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AyahEntry {
        AyahEntry(date: Date(), ayah: .placeholder, theme: .classic)
    }

    func getSnapshot(in context: Context, completion: @escaping (AyahEntry) -> Void) {
        let ayah = SettingsStore.shared.loadCurrentAyah() ?? .placeholder
        completion(AyahEntry(date: Date(), ayah: ayah, theme: SettingsStore.shared.selectedTheme))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AyahEntry>) -> Void) {
        let language = SettingsStore.shared.selectedLanguage
        let theme = SettingsStore.shared.selectedTheme
        let intervalMinutes = SettingsStore.shared.refreshMinutes

        Task {
            // Widget extensions CAN make network calls, but it's not guaranteed
            // to succeed reliably on every refresh, so we fall back to the
            // locally cached translation file when offline.
            let ayah: Ayah
            if let fetched = try? await QuranAPIService.shared.fetchRandomAyah(language: language) {
                ayah = fetched
                SettingsStore.shared.saveCurrentAyah(fetched)
            } else if let cached = await LanguageManager.shared.randomCachedAyah(for: language) {
                ayah = cached
            } else {
                ayah = SettingsStore.shared.loadCurrentAyah() ?? .placeholder
            }

            let now = Date()
            let nextRefresh = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: now) ?? now.addingTimeInterval(3600)
            let entry = AyahEntry(date: now, ayah: ayah, theme: theme)

            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }
}

struct QuranWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: AyahEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            RectangularLockScreenView(ayah: entry.ayah)
        case .accessoryInline:
            Text("\(entry.ayah.surahNameEnglish) \(entry.ayah.ayahNumber): \(entry.ayah.translationText)")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 1) {
                    Image(systemName: "book.closed.fill")
                        .font(.caption)
                    Text("\(entry.ayah.surahNumber):\(entry.ayah.ayahNumber)")
                        .font(.system(size: 11, weight: .semibold))
                }
            }
        default:
            // Home Screen widget families use the full themed styling
            HomeScreenView(ayah: entry.ayah, theme: entry.theme)
        }
    }
}

private struct RectangularLockScreenView: View {
    let ayah: Ayah

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ayah.arabicText)
                .font(.system(size: 14, weight: .semibold))
                .environment(\.layoutDirection, .rightToLeft)
                .lineLimit(1)
            Text(ayah.translationText)
                .font(.system(size: 11))
                .lineLimit(2)
            Text("\(ayah.surahNameEnglish) \(ayah.surahNumber):\(ayah.ayahNumber)")
                .font(.system(size: 9))
                .opacity(0.7)
        }
        .widgetAccentable()
    }
}

private struct HomeScreenView: View {
    let ayah: Ayah
    let theme: WidgetTheme

    var body: some View {
        VStack(spacing: 6) {
            Text(ayah.arabicText)
                .font(theme.arabicFont)
                .foregroundStyle(theme.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(ayah.translationText)
                .font(theme.translationFont)
                .foregroundStyle(theme.textColor.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(3)
            Text("\(ayah.surahNameEnglish) \(ayah.surahNumber):\(ayah.ayahNumber)")
                .font(.system(size: 10))
                .foregroundStyle(theme.textColor.opacity(0.6))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }
}

struct QuranWidget: Widget {
    let kind: String = "QuranWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuranWidgetProvider()) { entry in
            QuranWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName("Quran Verses")
        .description("Shows a Quran ayah with translation that refreshes on your schedule.")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
            .systemSmall,
            .systemMedium
        ])
    }
}
