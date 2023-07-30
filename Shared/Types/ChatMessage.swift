import SwiftUI
import LiveKit

struct ChatMessage: Codable, Hashable, Identifiable {

    var id: String?

    let timestamp: Int
    let message: String
    var participant: Participant?

    private enum CodingKeys: String, CodingKey {
        case timestamp = "timestamp",
             message = "message"
    }

    init(timestamp: Int = 0,
         message: String = "",
         participant: Participant? = nil) {

        self.id = UUID().uuidString
        self.timestamp = timestamp
        self.message = message
        self.participant = participant
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timestamp)
        hasher.combine(message)
    }
}
