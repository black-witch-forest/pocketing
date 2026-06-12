import SwiftUI

struct SpotTheBugView: View {
    let data: SpotTheBugChallengeData
    let onAnswer: (Bool) -> Void

    @State private var selectedLine: Int? = nil
    @State private var hasAnswered = false

    var body: some View {
        VStack(spacing: 12) {
            Text("TAP THE BUGGY LINE")
                .font(NeoFonts.caption)
                .foregroundColor(NeoColors.black)
                .tracking(2)

            // Code block with tappable lines
            VStack(spacing: 0) {
                ForEach(Array(data.codeLines.enumerated()), id: \.offset) { index, line in
                    Button {
                        guard !hasAnswered else { return }
                        selectedLine = index
                        hasAnswered = true
                        onAnswer(index == data.bugLineIndex)
                    } label: {
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(NeoColors.black.opacity(0.5))
                                .frame(width: 24, alignment: .trailing)

                            Text(line)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(NeoColors.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(lineBackground(for: index))
                    }
                    .disabled(hasAnswered)

                    if index < data.codeLines.count - 1 {
                        Divider()
                            .frame(height: 1)
                            .background(NeoColors.black.opacity(0.15))
                    }
                }
            }
            .background(Color(hex: "F5F5DC"))
            .overlay(
                Rectangle()
                    .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
            )
            .shadow(color: NeoColors.black, radius: 0, x: NeoMetrics.shadowOffset, y: NeoMetrics.shadowOffset)
        }
    }

    private func lineBackground(for index: Int) -> Color {
        guard hasAnswered else {
            return .clear
        }
        if index == data.bugLineIndex {
            return NeoColors.mintGreen.opacity(0.5)
        } else if index == selectedLine {
            return NeoColors.bloodRed.opacity(0.5)
        }
        return .clear
    }
}

#Preview {
    let sampleData = SpotTheBugChallengeData(
        codeLines: [
            "func transfer(from: Account, to: Account, amount: Int) {",
            "    lock.lock()",
            "    from.balance -= amount",
            "    to.balance += amount",
            "    // missing lock.unlock()",
            "}"
        ],
        bugLineIndex: 4,
        feedback: "The lock is never released, causing a deadlock on subsequent calls."
    )
    SpotTheBugView(data: sampleData) { correct in
        print("Answered: \(correct)")
    }
    .padding()
}
