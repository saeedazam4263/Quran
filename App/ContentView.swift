import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayVerseView()
                .tabItem { Label("Today", systemImage: "sun.max") }

            ThemePickerView()
                .tabItem { Label("Styling", systemImage: "paintbrush") }

            LanguageDownloadView()
                .tabItem { Label("Languages", systemImage: "globe") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
}
