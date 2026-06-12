import Foundation
import SwiftData

@Model
final class CardModel {
    @Attribute(.unique) var id: String
    var course: String
    var topic: String
    var primer: String
    var challengeType: String
    var challengeData: Data
    var bucket: Int
    var nextReviewDate: Date
    var timesAnswered: Int

    init(id: String = UUID().uuidString,
         course: String,
         topic: String,
         primer: String,
         challengeType: String,
         challengeData: Data,
         bucket: Int = 0,
         nextReviewDate: Date = .now,
         timesAnswered: Int = 0) {
        self.id = id
        self.course = course
        self.topic = topic
        self.primer = primer
        self.challengeType = challengeType
        self.challengeData = challengeData
        self.bucket = bucket
        self.nextReviewDate = nextReviewDate
        self.timesAnswered = timesAnswered
    }

    /// Decode the JSON blob into a typed challenge
    var decodedChallenge: DecodedChallenge? {
        guard let type = ChallengeType(rawValue: challengeType) else { return nil }
        let decoder = JSONDecoder()
        switch type {
        case .binaryChoice:
            guard let decoded = try? decoder.decode(BinaryChallengeData.self, from: challengeData) else { return nil }
            return .binaryChoice(decoded)
        case .spotTheBug:
            guard let decoded = try? decoder.decode(SpotTheBugChallengeData.self, from: challengeData) else { return nil }
            return .spotTheBug(decoded)
        case .fillBlank:
            guard let decoded = try? decoder.decode(FillBlankChallengeData.self, from: challengeData) else { return nil }
            return .fillBlank(decoded)
        }
    }
}
