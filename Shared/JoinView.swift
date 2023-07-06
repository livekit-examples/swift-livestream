import SwiftUI
import LiveKit

struct JoinView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    @State private var showDialog = false
    @State private var disconnectReason: DisconnectReason?

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Join Livestream")
                .font(.system(size: 30, weight: .bold))

            StyledTextField(title: "Your name", text: $roomCtx.identity)

            StyledTextField(title: "Livestream name", text: $roomCtx.roomName)

            Spacer()

            StyledButton(title: "Join", style: .primary, isBusy: roomCtx.connectBusy) {
                roomCtx.join()
            }

            StyledButton(title: "Back", isEnabled: !roomCtx.connectBusy) {
                roomCtx.backToWelcome()
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
