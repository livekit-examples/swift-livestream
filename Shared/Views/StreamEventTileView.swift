import SwiftUI
import LiveKit

struct StreamEventTileView: View {

    @EnvironmentObject var room: Room

    let entry: StreamEvent

    var body: some View {

        HStack(alignment: .top, spacing: 10) {

            Group {
                if let identity = entry.identity,
                   let participant = room.allParticipants.values.first(where: { $0.identity == identity }) {
                    AsyncImage(url: URL(string: "https://api.multiavatar.com/\(participant.identity).png")) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Circle()
                }
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 5) {

                if let identity = entry.identity {
                    Text(identity)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(entry.message)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
