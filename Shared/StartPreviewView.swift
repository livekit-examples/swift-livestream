import SwiftUI
import LiveKitComponents

struct StartPreviewView: View {

    @EnvironmentObject var appCtx: AppContext

    @State private var flag1 = true
    @State private var flag2 = true

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            PublisherVideoView()
                .padding(.vertical, 10)

            Text("After going live you’ll acquire a streaming link for sharing with your viewers.")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            StyledButton(title: "Go live", style: .primary) {
                appCtx.startPublisher()
            }

            StyledButton(title: "Back") {
                appCtx.backToPrepare()
            }
        }
        .padding()
    }
}
