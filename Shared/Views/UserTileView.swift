import SwiftUI
import LiveKit

struct UserTileView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var participant: Participant

    var body: some View {

        HStack(alignment: .center, spacing: 10) {

            Circle()
                .frame(width: 30, height: 30)

            Text(participant.identity)
                .font(.system(size: 14))
                .fontWeight(.bold)

            Spacer()

            if roomCtx.isStreamOwner {

                if !participant.canPublish && participant.handRaised {

                    StyledButton(title: "Accept",
                                 style: .secondary,
                                 size: .small,
                                 isFullWidth: false) {
                        roomCtx.inviteToStage(identity: participant.identity)
                    }
                }

                if participant.canPublish || participant.handRaised {

                    StyledButton(title: "Reject",
                                 style: .secondary,
                                 size: .small,
                                 isFullWidth: false) {
                        roomCtx.removeFromStage(identity: participant.identity)
                    }
                }
            }
        }
    }
}
