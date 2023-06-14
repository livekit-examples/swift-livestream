import SwiftUI
import LiveKit
import LiveKitComponents

struct StartPreviewView: View {

    @EnvironmentObject var appCtx: AppContext
    @EnvironmentObject var room: Room

    @State private var flag1 = true
    @State private var flag2 = true

    @State private var showDialog = false
    @State private var disconnectReason: DisconnectReason?

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            PublisherVideoPreview()
                .padding(.vertical, 10)

            Text("After going live you’ll acquire a streaming link for sharing with your viewers.")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            StyledButton(title: "Go live", style: .primary, isBusy: room.connectionState == .connecting) {
                appCtx.startPublisher()
            }

            StyledButton(title: "Back", isEnabled: !(room.connectionState == .connecting)) {
                appCtx.backToPrepare()
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
