import SwiftUI
import SwiftData

struct ArenaView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let course: String? // nil = Mix All

    @State private var cardManager: CardManager?
    @State private var dismissingCardID: String? = nil
    @State private var dismissOffset: CGFloat = 0
    @State private var showNext: [String: Bool] = [:]

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("← BACK")
                        .font(NeoFonts.button)
                        .foregroundColor(NeoColors.black)
                }

                Spacer()

                Text((course ?? "MIX ALL").uppercased())
                    .font(NeoFonts.caption)
                    .foregroundColor(NeoColors.black)
                    .tracking(2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(NeoColors.yellow)
            .overlay(
                Rectangle()
                    .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
            )

            // Card deck or empty state
            if let manager = cardManager, !manager.activeCards.isEmpty {
                ZStack {
                    let visibleCards = Array(manager.activeCards.prefix(3))

                    ForEach(Array(visibleCards.enumerated().reversed()), id: \.element.id) { index, card in
                        let isTop = index == 0
                        let isDismissing = card.id == dismissingCardID

                        CardView(card: card) { isCorrect in
                            manager.processAnswer(card: card, isCorrect: isCorrect)
                            withAnimation(NeoAnimation.spring) {
                                showNext[card.id] = true
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if showNext[card.id] == true {
                                Button {
                                    dismissCard(card: card)
                                } label: {
                                    Text("NEXT →")
                                }
                                .buttonStyle(NeoButtonStyle(backgroundColor: NeoColors.hotPink, foregroundColor: NeoColors.white))
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .scaleEffect(isTop ? 1.0 : 1.0 - 0.05 * CGFloat(index))
                        .offset(y: isDismissing ? dismissOffset : CGFloat(index) * 8)
                        .zIndex(isDismissing ? 10 : Double(visibleCards.count - index))
                        .allowsHitTesting(isTop && !isDismissing)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 20)
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Text("🎉")
                        .font(.system(size: 64))

                    Text("ALL CAUGHT UP!")
                        .font(NeoFonts.title)
                        .foregroundColor(NeoColors.black)

                    Text("No cards due right now.\nCheck back later!")
                        .font(NeoFonts.body)
                        .foregroundColor(NeoColors.black.opacity(0.6))
                        .multilineTextAlignment(.center)

                    Button {
                        dismiss()
                    } label: {
                        Text("← HOME")
                    }
                    .buttonStyle(NeoButtonStyle(backgroundColor: NeoColors.yellow))
                    .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(NeoColors.white)
        .navigationBarHidden(true)
        .onAppear {
            setupCardManager()
        }
    }

    private func setupCardManager() {
        let manager = CardManager(modelContext: modelContext)
        manager.currentCourse = course
        manager.loadCards()
        cardManager = manager
    }

    private func dismissCard(card: CardModel) {
        dismissingCardID = card.id

        withAnimation(.easeIn(duration: 0.3)) {
            dismissOffset = -1000
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showNext[card.id] = nil
            dismissingCardID = nil
            dismissOffset = 0
            cardManager?.removeTopCard()
        }
    }
}
