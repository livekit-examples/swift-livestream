import SwiftUI
import LiveKit

struct CreateStream: Codable {

    struct Metadata: Codable {

        let creatorIdentity: String
        let enableChat: Bool
        let allowParticipant: Bool

        private enum CodingKeys: String, CodingKey {
            case creatorIdentity = "creator_identity",
                 enableChat = "enable_chat",
                 allowParticipant = "allow_participant"
        }
    }

    let roomName: String
    let metadata: Metadata

    private enum CodingKeys: String, CodingKey {
        case roomName = "room_name",
             metadata
    }
}

struct CreateStreamResponse: Codable {

    struct ConnectionDetails: Codable {

        let wsURL: String
        let token: String

        private enum CodingKeys: String, CodingKey {
            case wsURL = "ws_url",
                 token = "token"
        }
    }

    let authToken: String
    let connectionDetails: ConnectionDetails

    private enum CodingKeys: String, CodingKey {
        case authToken = "auth_token",
             connectionDetails = "connection_details"
    }
}
