import SwiftUI

struct BinaryChoiceView: View {
    let data: BinaryChallengeData
    let onAnswer: (Bool) -> Void

    @State private var selectedIndex: Int? = nil
    @State private var hasAnswered = false

    var body: some View {
        VStack(spacing: 16) {
            // Scenario text
            Text(data.scenario)
                .font(NeoFonts.body)
                .foregroundColor(NeoColors.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Two massive vertical buttons
            ForEach(Array(data.options.enumerated()), id: \.offset) { index, option in
                Button {
                    guard !hasAnswered else { return }
                    selectedIndex = index
                    hasAnswered = true
                    onAnswer(index == data.correctIndex)
                } label: {
                    Text(option.uppercased())
                        .font(NeoFonts.button)
                        .foregroundColor(NeoColors.black)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(NeoButtonStyle(
                    backgroundColor: buttonColor(for: index)
                ))
                .disabled(hasAnswered)
            }
        }
    }

    private func buttonColor(for index: Int) -> Color {
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
    let sampleData = BinaryChallengeData(
        scenario: "Two threads are incrementing a shared counter without synchronization. Which primitive prevents the race condition?",
        options: ["Mutex", "Semaphore"],
        correctIndex: 0,
        feedback: "A mutex ensures mutual exclusion on the shared counter."
    )
    BinaryChoiceView(data: sampleData) { correct in
        print("Answered: \(correct)")
    }
    .padding()
}
