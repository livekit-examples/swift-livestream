import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject var appCtx: AppContext

    var body: some View {

        VStack(alignment: .center, spacing: 20) {

            Spacer()

            Image("AppIcon")
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding()

            VStack(alignment: .center, spacing: 10) {

                Text("Welcome!")
                    .font(.system(size: 30, weight: .bold))

                Text("Welcome to the LiveKit live streaming demo app. You can join or start your own stream. Hosted on LiveKit Cloud.")
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
            }

            Spacer()

            StyledButton(title: "Start a livestream", style: .primary) {
                appCtx.set(step: .streamerPrepare)
            }

            StyledButton(title: "Join a livestream") {
                appCtx.set(step: .viewerPrepare)
            }
        }
        .padding()
    }
}
