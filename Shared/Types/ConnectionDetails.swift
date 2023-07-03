
struct ConnectionDetails: Codable {

    let wsURL: String
    let token: String

    private enum CodingKeys: String, CodingKey {
        case wsURL = "ws_url",
             token = "token"
    }
}
