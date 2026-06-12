import SwiftUI

struct FillBlankView: View {
    let data: FillBlankChallengeData
    let onAnswer: (Bool) -> Void

    @State private var selectedIndex: Int? = nil
    @State private var hasAnswered = false

    var body: some View {
        VStack(spacing: 20) {
            // Display the snippet with the blank highlighted
            VStack(alignment: .leading, spacing: 8) {
                buildSnippetText()
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "F5F5DC"))
            .overlay(
                Rectangle()
                    .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
            )
            .shadow(color: NeoColors.black, radius: 0, x: NeoMetrics.shadowOffset, y: NeoMetrics.shadowOffset)

            // 3 pill buttons
            VStack(spacing: 10) {
                ForEach(Array(data.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        guard !hasAnswered else { return }
                        selectedIndex = index
                        hasAnswered = true
                        onAnswer(index == data.correctIndex)
                    } label: {
                        Text(option)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(NeoColors.black)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(NeoButtonStyle(
                        backgroundColor: pillColor(for: index)
                    ))
                    .disabled(hasAnswered)
                }
            }
        }
    }

    @ViewBuilder
    private func buildSnippetText() -> some View {
        let parts = data.snippet.components(separatedBy: "___")
        if parts.count == 2 {
            let blankText: String = hasAnswered && selectedIndex != nil
                ? data.options[selectedIndex!]
                : "___"
            let blankColor: Color = hasAnswered
                ? (selectedIndex == data.correctIndex ? Color(hex: "006400") : NeoColors.bloodRed)
                : NeoColors.electricBlue

            (Text(parts[0])
                .font(.system(size: 14, weight: .medium, design: .monospaced))
             + Text(blankText)
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(blankColor)
             + Text(parts[1])
                .font(.system(size: 14, weight: .medium, design: .monospaced)))
                .foregroundColor(NeoColors.black)
        } else {
            Text(data.snippet)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(NeoColors.black)
        }
    }

    private func pillColor(for index: Int) -> Color {
        guard hasAnswered else { return NeoColors.white }
        if index == data.correctIndex {
            return NeoColors.mintGreen
        } else if index == selectedIndex {
            return NeoColors.bloodRed
        }
        return NeoColors.white
    }
}

#Preview {
    let sampleData = FillBlankChallengeData(
        snippet: "let queue = DispatchQueue(label: \"sync\", attributes: ___)",
        options: [".concurrent", ".serial", ".background"],
        correctIndex: 0,
        feedback: "The .concurrent attribute allows multiple tasks to execute simultaneously on this queue."
    )
    FillBlankView(data: sampleData) { correct in
        print("Answered: \(correct)")
    }
    .padding()
}
