import Foundation

enum ChallengeType: String, Codable {
    case binaryChoice
    case spotTheBug
    case fillBlank
}

struct BinaryChallengeData: Codable {
    let scenario: String
    let options: [String]
    let correctIndex: Int
    let feedback: String
}

struct SpotTheBugChallengeData: Codable {
    let codeLines: [String]
    let bugLineIndex: Int
    let feedback: String
}

struct FillBlankChallengeData: Codable {
    let snippet: String
    let options: [String]
    let correctIndex: Int
    let feedback: String
}

/// A type-erased wrapper that lets us work with any challenge type
enum DecodedChallenge {
    case binaryChoice(BinaryChallengeData)
    case spotTheBug(SpotTheBugChallengeData)
    case fillBlank(FillBlankChallengeData)
}
