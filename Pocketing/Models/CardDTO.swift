import Foundation

/// Raw JSON representation of a card from content.json
struct CardDTO: Codable, Identifiable {
    let id: String
    let course: String
    let topic: String
    let primer: String
    let challengeType: String
    let challengeData: ChallengeDataDTO
}

/// The challengeData field is a union type — it may contain fields for any of the 3 challenge types.
/// We decode it as a flexible struct and consume only the relevant fields.
struct ChallengeDataDTO: Codable {
    // binaryChoice fields
    let scenario: String?
    let options: [String]?
    let correctIndex: Int?
    let feedback: String?

    // spotTheBug fields
    let codeLines: [String]?
    let bugLineIndex: Int?
    // feedback is shared

    // fillBlank fields
    let snippet: String?
    // options is shared
    // correctIndex is shared
    // feedback is shared
}
