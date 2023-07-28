import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject var roomCtx: RoomContext

    var body: some View {

        VStack(alignment: .center, spacing: 12) {

            Spacer()

            Image("Logo")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding()

            VStack(alignment: .center, spacing: 10) {

                Text("Welcome!")
                    .font(.system(size: 34, weight: .bold))

                Text("Welcome to the LiveKit live streaming demo app. You can join or start your own stream. Hosted on LiveKit Cloud.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .padding(.horizontal, 20)
            }

            Spacer()

            StyledButton(style: .primary) {
                roomCtx.set(step: .streamerPrepare)
            } label: {
                Text("Start a livestream")
            }

            StyledButton {
                roomCtx.set(step: .viewerPrepare)
            } label: {
                Text("Join a livestream")
            }
        }
        .padding()
    }
}
