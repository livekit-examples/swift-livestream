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

            StyledTextField(title: "URL", text: appCtx.$url)

            StyledTextField(title: "Token", text: appCtx.$token)

            Spacer()

            StyledButton(title: "Join", style: .primary, isBusy: room.connectionState == .connecting) {
                appCtx.join()
            }

            StyledButton(title: "Back", isEnabled: !(room.connectionState == .connecting)) {
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
