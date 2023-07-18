import SwiftUI
import LiveKit

struct StreamerPrepareView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    @State private var showDialog = false
    @State private var disconnectReason: DisconnectReason?

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            PublisherVideoPreview()
                .padding(.vertical, 10)

            StyledTextField(title: "Your name", text: $roomCtx.identity)

            // StyledTextField(title: "Livestream name", text: $roomCtx.roomName)

            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $roomCtx.enableChat)
            Toggle("Viewers can request to join", isOn: $roomCtx.viewersCanRequestToJoin)

            Spacer()

            StyledButton(title: "Go live", style: .primary, isBusy: roomCtx.connectBusy) {
                roomCtx.startPublisher()
            }

            StyledButton(title: "Back") {
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
