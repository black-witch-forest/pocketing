import SwiftUI

struct CardView: View {
    let card: CardModel
    let onAnswered: (Bool) -> Void

    @State private var isExpanded = false
    @State private var hasAnswered = false
    @State private var isCorrect = false
    @State private var feedbackText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header: Course + Topic
            VStack(alignment: .leading, spacing: 6) {
                Text(card.course.uppercased())
                    .font(NeoFonts.caption)
                    .foregroundColor(NeoColors.black.opacity(0.6))
                    .tracking(2)

                Text(card.topic.uppercased())
                    .font(NeoFonts.title)
                    .foregroundColor(NeoColors.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)

            // Primer text
            Text(card.primer)
                .font(NeoFonts.body)
                .foregroundColor(NeoColors.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)

            // Progressive disclosure
            if !isExpanded {
                // APPLY button
                Button {
                    withAnimation(NeoAnimation.spring) {
                        isExpanded = true
                    }
                } label: {
                    Text("APPLY")
                }
                .buttonStyle(NeoButtonStyle(backgroundColor: NeoColors.yellow))
            } else {
                // Challenge area
                Divider()
                    .frame(height: NeoMetrics.borderWidth)
                    .background(NeoColors.black)
                    .padding(.bottom, 16)

                // Render the appropriate challenge view
                challengeContent

                // Feedback area (shown after answering)
                if hasAnswered {
                    FeedbackFlashView(isCorrect: isCorrect, feedback: feedbackText)
                        .padding(.top, 16)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
        .neoCard(backgroundColor: NeoColors.white)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var challengeContent: some View {
        if let challenge = card.decodedChallenge {
            switch challenge {
            case .binaryChoice(let data):
                BinaryChoiceView(data: data) { correct in
                    handleAnswer(correct: correct, feedback: data.feedback)
                }
            case .spotTheBug(let data):
                SpotTheBugView(data: data) { correct in
                    handleAnswer(correct: correct, feedback: data.feedback)
                }
            case .fillBlank(let data):
                FillBlankView(data: data) { correct in
                    handleAnswer(correct: correct, feedback: data.feedback)
                }
            }
        }
    }

    private func handleAnswer(correct: Bool, feedback: String) {
        withAnimation(NeoAnimation.spring) {
            isCorrect = correct
            feedbackText = feedback
            hasAnswered = true
        }
        onAnswered(correct)
    }
}
