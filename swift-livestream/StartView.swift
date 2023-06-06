import SwiftUI

struct StartView: View {

    @EnvironmentObject var appCtx: AppContext

    @State private var flag1 = true
    @State private var flag2 = true

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {
            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            PublisherVideoView()
                .padding(.vertical, 10)

            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $flag1)
            Toggle("Viewers can request to join", isOn: $flag2)

            Text("After going live you’ll acquire a streaming link for sharing with your viewers.")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Button {
                appCtx.set(step: .stream)
            } label: {
                Text("Go live")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
                    .padding(.vertical, 7)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.purple)
            .cornerRadius(7)
        }
        .padding()
    }
}
