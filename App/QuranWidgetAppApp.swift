import SwiftUI
import WidgetKit

@main
struct QuranWidgetAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Make sure there's always a current ayah cached for the widget
                    // the very first time the app launches.
                    if SettingsStore.shared.loadCurrentAyah() == nil {
                        if let ayah = try? await QuranAPIService.shared.fetchRandomAyah(
                            language: SettingsStore.shared.selectedLanguage
                        ) {
                            SettingsStore.shared.saveCurrentAyah(ayah)
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                }
        }
    }
}
