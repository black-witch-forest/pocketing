import Foundation
import SwiftData

struct DataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<CardModel>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        // Load and parse JSON
        guard let url = Bundle.main.url(forResource: "content", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dtos = try? JSONDecoder().decode([CardDTO].self, from: data) else {
            return
        }

        // Insert into SwiftData
        let encoder = JSONEncoder()
        for dto in dtos {
            guard let challengeJSON = try? encoder.encode(dto.challengeData) else { continue }

            let card = CardModel(
                id: dto.id,
                course: dto.course,
                topic: dto.topic,
                primer: dto.primer,
                challengeType: dto.challengeType,
                challengeData: challengeJSON
            )
            context.insert(card)
        }

        try? context.save()
    }
}
