import SwiftUI
import WidgetKit

struct ThemePickerView: View {
    @AppStorage(StorageKey.selectedThemeID, store: AppGroup.sharedDefaults) private var themeID = WidgetTheme.classic.rawValue
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(WidgetTheme.allCases) { theme in
                        ThemeCard(theme: theme, isSelected: theme.rawValue == themeID)
                            .onTapGesture {
                                themeID = theme.rawValue
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Styling")
        }
    }
}

private struct ThemeCard: View {
    let theme: WidgetTheme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            LockScreenPreview(ayah: .placeholder, theme: theme)
                .frame(height: 100)

            Text(theme.displayName)
                .font(.subheadline.weight(.medium))
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 3)
        )
    }
}

#Preview {
    ThemePickerView()
}
