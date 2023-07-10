import SwiftUI
import LiveKit

struct MessageBarView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    let moreAction: () -> Void

    var body: some View {

        let isCameraEnabled = room.localParticipant?.isCameraEnabled() ?? false
        let isMicEnabled = room.localParticipant?.isMicrophoneEnabled() ?? false

        HStack {

            TextField("Type your message...", text: $roomCtx.message, axis: .vertical)
                .lineLimit(5)
                .font(.system(size: 14))
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(5)
                .frame(maxWidth: .infinity)

            StyledButton(title: "Send",
                         style: .secondary,
                         size: .small,
                         isFullWidth: false,
                         isEnabled: roomCtx.canSendMessage) {

                roomCtx.send()
            }

            if roomCtx.isStreamHost {

                Button {
                    Task {
                        try await room.localParticipant?.setCamera(enabled: !isCameraEnabled)
                    }
                } label: {
                    Image(systemName: isCameraEnabled ? "video.fill" : "video.slash")
                        .foregroundColor(isCameraEnabled ? Color.green : Color.gray)
                }

                Button {
                    Task {
                        try await room.localParticipant?.setMicrophone(enabled: !isMicEnabled)
                    }
                } label: {
                    Image(systemName: isMicEnabled ? "mic.fill" : "mic.slash")
                        .foregroundColor(isMicEnabled ? Color.orange : Color.gray)
                }

            }

            Button {
                moreAction()
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(Color("Secondary"))
            }

            // if showJoinButton {
            //
            //     Button {
            //         moreAction()
            //     } label: {
            //         Image(systemName: "ellipsis")
            //             .rotationEffect(.degrees(90))
            //     }
            //
            // }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
    }
}
