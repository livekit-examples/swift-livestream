
struct JoinStreamRequest: Codable {

    let roomName: String
    let identity: String

    private enum CodingKeys: String, CodingKey {
        case roomName = "room_name",
             identity
    }
}

struct JoinStreamResponse: Codable {

    let authToken: String
    let connectionDetails: ConnectionDetails

    private enum CodingKeys: String, CodingKey {
        case authToken = "auth_token",
             connectionDetails = "connection_details"
    }
}
