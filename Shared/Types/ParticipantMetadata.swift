import SwiftUI

struct ParticipantMetadata: Codable {

    let handRaised: Bool
    let invitedToStage: Bool
    let avatarImage: String

    private enum CodingKeys: String, CodingKey {
        case handRaised = "hand_raised",
             invitedToStage = "invited_to_stage",
             avatarImage = "avatar_image"
    }

    init(hand_raised: Bool = false,
         invited_to_stage: Bool = false,
         avatar_image: String = "") {

        self.handRaised = hand_raised
        self.invitedToStage = invited_to_stage
        self.avatarImage = avatar_image
    }
}

extension ParticipantMetadata {

    var avatarURL: URL? {
        guard let url = URL(string: avatarImage) else {
            logger.warning("Failed to parse avatar url \(avatarImage)")
            return nil
        }

        return url
    }
}
