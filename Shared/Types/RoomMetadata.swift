struct RoomMetadata: Codable {

    let enableChat: Bool
    let creatorIdentity: Bool
    let allowParticipant: Bool

    private enum CodingKeys: String, CodingKey {
        case enableChat = "enable_chat",
             creatorIdentity = "creator_identity",
             allowParticipant = "allow_participant"
    }

    init(enableChat: Bool = false,
         creatorIdentity: Bool = false,
         allowParticipant: Bool = false) {

        self.enableChat = enableChat
        self.creatorIdentity = creatorIdentity
        self.allowParticipant = allowParticipant
    }
}
