import SwiftUI
import LiveKit

struct ViewerPrepareView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    @State private var showDialog = false
    @State private var disconnectReason: DisconnectReason?

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Join Livestream")
                .font(.system(size: 30, weight: .bold))

            StyledTextField(title: "Livestream code",
                            placeholder: "Type livestream code shared by stream host...",
                            text: $roomCtx.roomName)

            StyledTextField(title: "Your name",
                            placeholder: "Type your name...",
                            text: $roomCtx.identity)

            Spacer()

            StyledButton(style: .primary,
                         isBusy: roomCtx.connectBusy,
                         isEnabled: roomCtx.canJoinLive) {
                roomCtx.join()
            } label: {
                Text("Join")
            }

            StyledButton(isEnabled: !roomCtx.connectBusy) {
                roomCtx.backToWelcome()
            } label: {
                Text("Back")
            }
        }
        .padding()
        .onChange(of: room.connectionState) { _ in
            if case .disconnected(let reason) = room.connectionState {
                self.disconnectReason = reason
                self.showDialog = true
            }
        }
        .alert(isPresented: $showDialog) {
            Alert(title: Text("Disconnected"),
                  message: Text("Reason: " + (disconnectReason != nil
                                                ? String(describing: disconnectReason!)
                                                : "Unknown")))
        }
    }
}
