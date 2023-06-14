import SwiftUI
import LiveKit

struct UserTileView: View {

    @EnvironmentObject var participant: Participant

    var body: some View {

        HStack(alignment: .center, spacing: 10) {
            Circle()
                .frame(width: 30, height: 30)

            Text(participant.identity)
                .font(.system(size: 14))
                .fontWeight(.bold)

            Spacer()
        }
    }
}
