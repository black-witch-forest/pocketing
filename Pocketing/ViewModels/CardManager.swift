import Foundation
import SwiftData
import SwiftUI

@Observable
class CardManager {
    private var modelContext: ModelContext
    var activeCards: [CardModel] = []
    var currentCourse: String? // nil = Mix All

    private let bufferSize = 10
    private let refillThreshold = 3
    private let treadmillBatchSize = 5

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - SRS Logic

    func processAnswer(card: CardModel, isCorrect: Bool) {
        if isCorrect {
            card.bucket += 1
            card.nextReviewDate = nextReviewDate(for: card.bucket)
        } else {
            card.bucket = 0
            card.nextReviewDate = .now
        }
        card.timesAnswered += 1
        try? modelContext.save()
    }

    private func nextReviewDate(for bucket: Int) -> Date {
        let calendar = Calendar.current
        let days: Int
        switch bucket {
        case 1: days = 1
        case 2: days = 3
        case 3: days = 7
        default: days = 30 // bucket 4+
        }
        return calendar.date(byAdding: .day, value: days, to: .now) ?? .now
    }

    // MARK: - Priority Queue

    func loadCards() {
        activeCards = []
        refillBuffer()
    }

    func removeTopCard() {
        guard !activeCards.isEmpty else { return }
        activeCards.removeFirst()
        if activeCards.count < refillThreshold {
            refillBuffer()
        }
    }

    private func refillBuffer() {
        let needed = bufferSize - activeCards.count
        guard needed > 0 else { return }

        let existingIDs = Set(activeCards.map { $0.id })
        var newCards: [CardModel] = []

        // Priority 1: Due cards
        let dueCards = fetchDueCards().filter { !existingIDs.contains($0.id) }
        newCards.append(contentsOf: dueCards)

        // Priority 2: Unseen cards
        if newCards.count < needed {
            let newCardIDs = Set(newCards.map { $0.id })
            let unseenCards = fetchUnseenCards().filter {
                !existingIDs.contains($0.id) && !newCardIDs.contains($0.id)
            }
            let remaining = needed - newCards.count
            newCards.append(contentsOf: unseenCards.prefix(remaining))
        }

        // Priority 3: Treadmill (mastered)
        if newCards.count < needed {
            let allUsedIDs = existingIDs.union(Set(newCards.map { $0.id }))
            let masteredCards = fetchMasteredCards().filter {
                !allUsedIDs.contains($0.id)
            }
            let remaining = needed - newCards.count
            newCards.append(contentsOf: masteredCards.prefix(remaining))
        }

        activeCards.append(contentsOf: newCards)
    }

    private func fetchDueCards() -> [CardModel] {
        let now = Date.now
        var descriptor = FetchDescriptor<CardModel>(
            predicate: #Predicate<CardModel> { card in
                card.nextReviewDate <= now
            },
            sortBy: [SortDescriptor(\.nextReviewDate, order: .forward)]
        )
        if let course = currentCourse {
            descriptor.predicate = #Predicate<CardModel> { card in
                card.nextReviewDate <= now && card.course == course
            }
        }
        descriptor.fetchLimit = bufferSize
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchUnseenCards() -> [CardModel] {
        var descriptor = FetchDescriptor<CardModel>(
            predicate: #Predicate<CardModel> { card in
                card.bucket == 0 && card.timesAnswered == 0
            }
        )
        if let course = currentCourse {
            descriptor.predicate = #Predicate<CardModel> { card in
                card.bucket == 0 && card.timesAnswered == 0 && card.course == course
            }
        }
        descriptor.fetchLimit = bufferSize
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchMasteredCards() -> [CardModel] {
        var descriptor = FetchDescriptor<CardModel>(
            predicate: #Predicate<CardModel> { card in
                card.bucket >= 2
            }
        )
        if let course = currentCourse {
            descriptor.predicate = #Predicate<CardModel> { card in
                card.bucket >= 2 && card.course == course
            }
        }
        descriptor.fetchLimit = treadmillBatchSize
        let results = (try? modelContext.fetch(descriptor)) ?? []
        return results.shuffled()
    }

    // MARK: - Course List

    func availableCourses() -> [String] {
        let descriptor = FetchDescriptor<CardModel>()
        let allCards = (try? modelContext.fetch(descriptor)) ?? []
        return Array(Set(allCards.map { $0.course })).sorted()
    }
}
