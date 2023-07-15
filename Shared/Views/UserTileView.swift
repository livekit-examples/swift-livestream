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

    var canInvite: Bool {
        roomCtx.isStreamOwner && !isCreator && !participant.canPublish && !participant.invited
    }

    var canReject: Bool {
        roomCtx.isStreamOwner && !isCreator && (participant.canPublish || participant.handRaised || participant.invited)
    }

    var canJoin: Bool {
        isMe && !participant.canPublish && participant.invited
    }

    var canCancel: Bool {
        !isCreator && isMe && (participant.canPublish || participant.handRaised || participant.invited)
    }

    var roleLabel: some View {
        Text(isCreator ? "Host" : "Co-Host")
            .textCase(.uppercase)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(Color.gray)
    }

    func actionButton(title: String,
                      style: StyledButton.Style,
                      isBusy: Bool = false,
                      action: @escaping () -> Void) -> some View {

        StyledButton(title: title,
                     style: style,
                     size: .small,
                     isFullWidth: false,
                     isBusy: isBusy,
                     action: action)
    }

    var body: some View {

        HStack(alignment: .center, spacing: 10) {

            AsyncImage(url: URL(string: "https://api.multiavatar.com/\(participant.identity).png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .frame(width: 30, height: 30)

            Text(participant.identity)
                .font(.system(size: 14, weight: .bold))

            if isCreator || isCoHost {
                roleLabel
            }

            Spacer()

            if canInvite {
                actionButton(title: participant.handRaised ? "Accept" : "Invite",
                             style: .secondary,
                             isBusy: roomCtx.inviteBusy.contains(participant.identity)) {

                    roomCtx.inviteToStage(identity: participant.identity)
                }
            }

            if canReject {
                actionButton(title: participant.invited ? "Cancel" : "Reject",
                             style: .destructive) {

                    roomCtx.removeFromStage(identity: participant.identity)
                }
            }

            if canJoin {
                actionButton(title: "Join",
                             style: .secondary) {

                    roomCtx.raiseHand()
                }
            }

            if canCancel {
                actionButton(title: "Cancel",
                             style: .destructive) {

                    roomCtx.removeFromStage()
                }
            }
        }
    }
}
