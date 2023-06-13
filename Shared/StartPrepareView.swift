import SwiftUI

struct StartPrepareView: View {

    @EnvironmentObject var appCtx: AppContext

    @State private var flag1 = true
    @State private var flag2 = true

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            StyledTextField(title: "URL", text: appCtx.$url)

            StyledTextField(title: "Token", text: appCtx.$token)

            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $flag1)
            Toggle("Viewers can request to join", isOn: $flag2)

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
