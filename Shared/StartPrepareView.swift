import SwiftUI

struct StartPrepareView: View {

    @EnvironmentObject var appCtx: AppContext

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            StyledTextField(title: "Your name", text: $appCtx.identity)

            StyledTextField(title: "Livestream name", text: $appCtx.roomName)

            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $appCtx.enableChat)
            Toggle("Viewers can request to join", isOn: $appCtx.viewersCanRequestToJoin)

            Spacer()

            StyledButton(title: "Continue", style: .primary) {
                appCtx.set(step: .streamerPreview)
            }

            StyledButton(title: "Back") {
                appCtx.backToWelcome()
            }
        }
        .padding()
    }
}
