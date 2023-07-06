import SwiftUI

struct StartPrepareView: View {

    @EnvironmentObject var roomCtx: RoomContext

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            StyledTextField(title: "Your name", text: $roomCtx.identity)

            StyledTextField(title: "Livestream name", text: $roomCtx.roomName)

            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $roomCtx.enableChat)
            Toggle("Viewers can request to join", isOn: $roomCtx.viewersCanRequestToJoin)

            Spacer()

            StyledButton(title: "Continue", style: .primary) {
                roomCtx.set(step: .streamerPreview)
            }

            StyledButton(title: "Back") {
                roomCtx.backToWelcome()
            }
        }
        .padding()
    }
}
