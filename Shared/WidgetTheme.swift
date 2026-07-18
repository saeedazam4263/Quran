import SwiftUI

/// A stylable theme for the Lock Screen widget. Lock Screen widgets are
/// mostly monochrome/tinted by iOS, but these control layout, font, and
/// which decorative accents render behind the accessory family widgets,
/// plus full styling used in the in-app preview and Home Screen widget.
enum WidgetTheme: String, CaseIterable, Codable, Identifiable {
    case minimal
    case classic
    case emeraldPattern
    case nightMode
    case goldFrame
    case parchment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .minimal: return "Minimal"
        case .classic: return "Classic"
        case .emeraldPattern: return "Emerald Pattern"
        case .nightMode: return "Night Mode"
        case .goldFrame: return "Gold Frame"
        case .parchment: return "Parchment"
        }
    }

    var arabicFont: Font {
        switch self {
        case .minimal, .nightMode: return .system(size: 20, weight: .medium, design: .rounded)
        case .classic, .goldFrame: return .system(size: 20, weight: .semibold, design: .serif)
        case .emeraldPattern, .parchment: return .custom("Damascus", size: 20)
        }
    }

    var translationFont: Font {
        switch self {
        case .minimal, .nightMode: return .system(size: 13, weight: .regular, design: .rounded)
        default: return .system(size: 13, weight: .regular, design: .serif)
        }
    }

    /// Background used only in Home Screen widget / in-app preview.
    /// Lock Screen accessory widgets ignore custom backgrounds by design (iOS tints them).
    var background: LinearGradient {
        switch self {
        case .minimal:
            return LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom)
        case .classic:
            return LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .emeraldPattern:
            return LinearGradient(colors: [Color(hex: "0B6E4F"), Color(hex: "08A045")], startPoint: .top, endPoint: .bottom)
        case .nightMode:
            return LinearGradient(colors: [Color(hex: "0D1117"), Color(hex: "1A1F29")], startPoint: .top, endPoint: .bottom)
        case .goldFrame:
            return LinearGradient(colors: [Color(hex: "2B2200"), Color(hex: "4A3B00")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .parchment:
            return LinearGradient(colors: [Color(hex: "F3E9D2"), Color(hex: "E8D9B5")], startPoint: .top, endPoint: .bottom)
        }
    }

    var textColor: Color {
        switch self {
        case .minimal: return .black
        case .parchment: return Color(hex: "3E2F1C")
        default: return .white
        }
    }

    var accentColor: Color {
        switch self {
        case .goldFrame: return Color(hex: "D4AF37")
        case .emeraldPattern: return Color(hex: "B7F0C1")
        default: return .accentColor
        }
    }

    var showsDecorativeBorder: Bool {
        switch self {
        case .goldFrame, .emeraldPattern, .parchment: return true
        default: return false
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
