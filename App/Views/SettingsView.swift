import SwiftUI
import WidgetKit

struct SettingsView: View {
    @AppStorage(StorageKey.refreshMinutes, store: AppGroup.sharedDefaults) private var refreshMinutes = 60
    @State private var minutesText: String = ""
    @State private var showSavedConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Refresh every")
                        Spacer()
                        TextField("minutes", text: $minutesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 70)
                        Text("min")
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Minimum 15 minutes. iOS ultimately decides exact widget refresh timing to save battery, but this sets your target interval and is used as the widget's timeline budget.")
                }

                Section {
                    Button("Save") {
                        let value = Int(minutesText) ?? refreshMinutes
                        refreshMinutes = max(15, value)
                        minutesText = "\(refreshMinutes)"
                        WidgetCenter.shared.reloadAllTimelines()
                        showSavedConfirmation = true
                    }
                }

                Section("Add to Lock Screen") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Touch and hold your Lock Screen, then tap Customize.")
                        Text("2. Tap the widget area below the clock.")
                        Text("3. Search for “Quran Verses” and add it.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .onAppear { minutesText = "\(refreshMinutes)" }
            .alert("Saved", isPresented: $showSavedConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Widget will target refreshing every \(refreshMinutes) minutes.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
