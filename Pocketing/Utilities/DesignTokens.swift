import SwiftUI

// MARK: - Colors
enum NeoColors {
    static let black = Color(hex: "000000")
    static let white = Color(hex: "FFFFFF")
    static let yellow = Color(hex: "FFD700")
    static let hotPink = Color(hex: "FF69B4")
    static let electricBlue = Color(hex: "0000FF")
    static let mintGreen = Color(hex: "98FB98")
    static let bloodRed = Color(hex: "FF0000")

    /// Get accent color for a given course name
    static func accent(for course: String) -> Color {
        switch course.lowercased() {
        case "concurrency": return hotPink
        case "data structures": return electricBlue
        case "operating systems": return yellow
        default: return hotPink
        }
    }
}

// MARK: - Metrics
enum NeoMetrics {
    static let borderWidth: CGFloat = 3
    static let shadowOffset: CGFloat = 4
    static let cornerRadius: CGFloat = 0
    static let cardPadding: CGFloat = 20
    static let gridSpacing: CGFloat = 16
}

// MARK: - Fonts
enum NeoFonts {
    static let title = Font.system(size: 28, weight: .bold)
    static let body = Font.system(size: 16, weight: .medium)
    static let caption = Font.system(size: 12, weight: .semibold)
    static let button = Font.system(size: 18, weight: .bold)
}

// MARK: - Animation
enum NeoAnimation {
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
