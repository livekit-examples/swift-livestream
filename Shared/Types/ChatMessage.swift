import SwiftUI
import LiveKit

struct ChatMessage: Codable {

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

        self.timestamp = timestamp
        self.message = message
        self.participant = participant
    }
}
