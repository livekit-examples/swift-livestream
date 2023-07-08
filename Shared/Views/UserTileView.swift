import SwiftUI
import LiveKit

struct UserTileView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room
    @EnvironmentObject var participant: Participant

    var isMe: Bool {
        room.localParticipant?.identity == participant.identity
    }

    var isCreator: Bool {
        room.typedMetadata.creatorIdentity == participant.identity
    }

    var isCoHost: Bool {
        !isCreator && participant.canPublish
    }

    var body: some View {

        HStack(alignment: .center, spacing: 10) {

            Circle()
                .frame(width: 30, height: 30)

            Text(participant.identity)
                .font(.system(size: 14, weight: .bold))

            if isCreator {
                Text("Host")
                    .textCase(.uppercase)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.gray)
            }

            if isCoHost {
                Text("Co-Host")
                    .textCase(.uppercase)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.gray)
            }

            Spacer()

            if roomCtx.isStreamOwner && !isCreator {

                if !participant.canPublish {

                    StyledButton(title: participant.handRaised ? "Accept" : "Invite",
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

            } else {

                if isMe && !participant.canPublish && participant.invited {

                    StyledButton(title: "Join",
                                 style: .secondary,
                                 size: .small,
                                 isFullWidth: false) {

                        roomCtx.raiseHand()
                    }
                }
            }
        }
    }
}
