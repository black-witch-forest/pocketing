import SwiftUI

// MARK: - Neo Border + Shadow Modifier
struct NeoBorderModifier: ViewModifier {
    var backgroundColor: Color = NeoColors.white

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .overlay(
                Rectangle()
                    .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
            )
            .shadow(
                color: NeoColors.black,
                radius: 0,
                x: NeoMetrics.shadowOffset,
                y: NeoMetrics.shadowOffset
            )
    }
}

// MARK: - Neo Card Modifier (for the main card component)
struct NeoCardModifier: ViewModifier {
    var backgroundColor: Color = NeoColors.white

    func body(content: Content) -> some View {
        content
            .padding(NeoMetrics.cardPadding)
            .modifier(NeoBorderModifier(backgroundColor: backgroundColor))
    }
}

// MARK: - Neo Button Style
struct NeoButtonStyle: ButtonStyle {
    var backgroundColor: Color = NeoColors.yellow
    var foregroundColor: Color = NeoColors.black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(NeoFonts.button)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay(
                Rectangle()
                    .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
            )
            .shadow(
                color: NeoColors.black,
                radius: 0,
                x: configuration.isPressed ? 1 : NeoMetrics.shadowOffset,
                y: configuration.isPressed ? 1 : NeoMetrics.shadowOffset
            )
            .offset(
                x: configuration.isPressed ? 3 : 0,
                y: configuration.isPressed ? 3 : 0
            )
            .animation(NeoAnimation.spring, value: configuration.isPressed)
    }
}

// MARK: - Neo Course Button Style (for home screen grid)
struct NeoCourseButtonStyle: ButtonStyle {
    var accentColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(NeoFonts.title)
            .foregroundColor(NeoColors.black)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(accentColor)
            .overlay(
                Rectangle()
                    .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
            )
            .shadow(
                color: NeoColors.black,
                radius: 0,
                x: configuration.isPressed ? 1 : NeoMetrics.shadowOffset,
                y: configuration.isPressed ? 1 : NeoMetrics.shadowOffset
            )
            .offset(
                x: configuration.isPressed ? 3 : 0,
                y: configuration.isPressed ? 3 : 0
            )
            .animation(NeoAnimation.spring, value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func neoBorder(backgroundColor: Color = NeoColors.white) -> some View {
        modifier(NeoBorderModifier(backgroundColor: backgroundColor))
    }

    func neoCard(backgroundColor: Color = NeoColors.white) -> some View {
        modifier(NeoCardModifier(backgroundColor: backgroundColor))
    }
}
