import SwiftUI
import LiveKit

struct JoinView: View {

    @EnvironmentObject var appCtx: AppContext
    @EnvironmentObject var room: Room

    @State private var showDialog = false
    @State private var disconnectReason: DisconnectReason?

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Join Livestream")
                .font(.system(size: 30, weight: .bold))

            StyledTextField(title: "Your name", text: $appCtx.identity)

            StyledTextField(title: "Livestream name", text: $appCtx.roomName)

            Spacer()

            StyledButton(title: "Join", style: .primary, isBusy: appCtx.connectBusy) {
                appCtx.join()
            }

            StyledButton(title: "Back", isEnabled: !appCtx.connectBusy) {
                appCtx.backToWelcome()
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
