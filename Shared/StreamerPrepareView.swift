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

            StyledTextField(title: "Your name",
                            placeholder: "Type your name...",
                            text: $roomCtx.identity)

            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $roomCtx.enableChat)
            Toggle("Viewers can request to join", isOn: $roomCtx.viewersCanRequestToJoin)

            Spacer()

            StyledButton(style: .primary,
                         isBusy: roomCtx.connectBusy,
                         isEnabled: roomCtx.canGoLive) {
                roomCtx.startPublisher()
            } label: {
                Text("Go live")
            }

            StyledButton {
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
