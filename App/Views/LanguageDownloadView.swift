import SwiftUI
import WidgetKit

struct LanguageDownloadView: View {
    @StateObject private var manager = LanguageManager.shared
    @AppStorage(StorageKey.selectedLanguageCode, store: AppGroup.sharedDefaults) private var selectedCode = SupportedLanguages.bundledDefault.code

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("English is built in. Download other languages to use them for the widget translation — this only needs to happen once and then works offline.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Translations") {
                    ForEach(SupportedLanguages.all) { language in
                        LanguageRow(
                            language: language,
                            isSelected: language.code == selectedCode,
                            isDownloaded: manager.isDownloaded(language),
                            progress: manager.downloadProgress[language.code]
                        ) {
                            selectedCode = language.code
                            WidgetCenter.shared.reloadAllTimelines()
                        } onDownload: {
                            Task {
                                try? await manager.download(language)
                            }
                        } onDelete: {
                            manager.delete(language)
                            if selectedCode == language.code {
                                selectedCode = SupportedLanguages.bundledDefault.code
                            }
                        }
                    }
                }
            }
            .navigationTitle("Languages")
        }
    }
}

private struct LanguageRow: View {
    let language: QuranLanguage
    let isSelected: Bool
    let isDownloaded: Bool
    let progress: Double?
    let onSelect: () -> Void
    let onDownload: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(language.displayName)
                if let progress, progress < 1.0 {
                    ProgressView(value: progress)
                        .frame(width: 120)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            }

            if language.code == SupportedLanguages.bundledDefault.code || isDownloaded {
                Button(isSelected ? "Selected" : "Use") { onSelect() }
                    .buttonStyle(.bordered)
                    .disabled(isSelected)

                if language.code != SupportedLanguages.bundledDefault.code {
                    Button(role: .destructive) { onDelete() } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            } else {
                Button("Download") { onDownload() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    LanguageDownloadView()
}
