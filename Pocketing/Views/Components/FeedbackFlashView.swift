import SwiftUI

struct FeedbackFlashView: View {
    let isCorrect: Bool
    let feedback: String

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Text(isCorrect ? "✓" : "✗")
                .font(.system(size: 48, weight: .black))
                .foregroundColor(NeoColors.black)

            // Status
            Text(isCorrect ? "CORRECT" : "INCORRECT")
                .font(NeoFonts.title)
                .foregroundColor(NeoColors.black)

            // Feedback text
            Text(feedback)
                .font(NeoFonts.body)
                .foregroundColor(NeoColors.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(NeoMetrics.cardPadding)
        .frame(maxWidth: .infinity)
        .background(isCorrect ? NeoColors.mintGreen : NeoColors.bloodRed)
        .overlay(
            Rectangle()
                .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
        )
    }
}

#Preview("Correct") {
    FeedbackFlashView(isCorrect: true, feedback: "Great job! Mutex is indeed the correct synchronization primitive here.")
        .padding()
}

#Preview("Incorrect") {
    FeedbackFlashView(isCorrect: false, feedback: "Not quite. A semaphore would not prevent the race condition in this scenario.")
        .padding()
}
