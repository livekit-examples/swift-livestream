struct ParticipantMetadata: Codable {

    let handRaised: Bool
    let invitedToStage: Bool

    private enum CodingKeys: String, CodingKey {
        case handRaised = "hand_raised",
             invitedToStage = "invited_to_stage"
    }

    init(hand_raised: Bool = false, invited_to_stage: Bool = false) {
        self.handRaised = hand_raised
        self.invitedToStage = invited_to_stage
    }
}
