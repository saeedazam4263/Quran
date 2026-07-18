import SwiftUI
import WidgetKit

struct TodayVerseView: View {
    @AppStorage(StorageKey.selectedThemeID, store: AppGroup.sharedDefaults) private var themeID = WidgetTheme.classic.rawValue
    @State private var ayah: Ayah = SettingsStore.shared.loadCurrentAyah() ?? .placeholder
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var theme: WidgetTheme { WidgetTheme(rawValue: themeID) ?? .classic }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Live preview of what the widget will roughly look like
                    LockScreenPreview(ayah: ayah, theme: theme)
                        .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(ayah.arabicText)
                            .font(.system(size: 26, weight: .semibold))
                            .multilineTextAlignment(.trailing)
                            .environment(\.layoutDirection, .rightToLeft)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        Text(ayah.translationText)
                            .font(.body)
                            .foregroundStyle(.secondary)

                        Text("\(ayah.surahNameEnglish) \(ayah.surahNumber):\(ayah.ayahNumber)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task { await refresh() }
                    } label: {
                        Label(isLoading ? "Fetching…" : "New Verse Now", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Today's Ayah")
        }
    }

    private func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let language = SettingsStore.shared.selectedLanguage
            let newAyah = try await QuranAPIService.shared.fetchRandomAyah(language: language)
            ayah = newAyah
            SettingsStore.shared.saveCurrentAyah(newAyah)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            // Fall back to a cached offline verse if network fails
            if let cached = await LanguageManager.shared.randomCachedAyah(for: SettingsStore.shared.selectedLanguage) {
                ayah = cached
                SettingsStore.shared.saveCurrentAyah(cached)
            } else {
                errorMessage = "Couldn't fetch a new verse. Check your connection."
            }
        }
    }
}

/// A rough visual approximation of the Lock Screen widget for in-app preview.
/// Real Lock Screen accessory widgets are rendered by iOS itself (tinted,
/// monochrome), so this preview is illustrative rather than pixel-exact.
struct LockScreenPreview: View {
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
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(theme.background)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(theme.accentColor.opacity(theme.showsDecorativeBorder ? 0.8 : 0), lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    TodayVerseView()
}
