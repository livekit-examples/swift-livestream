import SwiftUI
import LiveKit

struct ChatMessage: Codable, Identifiable {

    let id: String
    var participant: Participant?

    // Codable
    let timestamp: Int
    let message: String

    private enum CodingKeys: String, CodingKey {
        case timestamp = "timestamp",
             message = "message"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.message = try container.decode(String.self, forKey: .message)
    }

    init(timestamp: Int = 0,
         message: String = "",
         participant: Participant? = nil) {

        self.id = UUID().uuidString
        self.timestamp = timestamp
        self.message = message
        self.participant = participant
    }
}
