import SwiftUI
import LiveKit
import SwiftUIBackports

struct MessageBarView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    @FocusState var focusFields: StreamView.TextFields?

    let moreAction: () -> Void

    var body: some View {

        let isCameraEnabled = room.localParticipant?.isCameraEnabled() ?? false
        let isMicEnabled = room.localParticipant?.isMicrophoneEnabled() ?? false

        HStack {

            TextField("", text: $roomCtx.message, axis: .vertical)
                .focused($focusFields, equals: .message)
                .lineLimit(5)
                .font(.system(size: 12))
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(6)
                .frame(maxWidth: .infinity)

            StyledButton(title: "Send",
                         style: .secondary,
                         size: .small,
                         isFullWidth: false,
                         isEnabled: roomCtx.canSendMessage) {

                roomCtx.send()
            }

            if !roomCtx.isStreamHost {

                let handRaised = room.localParticipant?.typedMetadata.handRaised ?? false

                Button {
                    if handRaised {
                        roomCtx.leave()
                    } else {
                        roomCtx.raiseHand()
                    }
                } label: {
                    Image(systemName: handRaised ? "hand.wave.fill" : "hand.wave")
                        .foregroundColor(handRaised ? Color.red : Color.gray)
                }
            }

            Button {
                moreAction()
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(Color("Secondary"))
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
    }
}
