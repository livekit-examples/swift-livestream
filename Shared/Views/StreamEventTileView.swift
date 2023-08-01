import SwiftUI
import LiveKit
import NukeUI

@MainActor
func image(for participant: Participant?) -> some View {
    Group {
        if let participant = participant {
            LazyImage(url: URL(string: "https://api.multiavatar.com/\(participant.identity).png")) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.1))
                }
            }
        } else {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.1))
        }
    }
    .background(Color.clear)
    .clipShape(Circle())
}

struct StreamEventTileView: View {

    @EnvironmentObject var room: Room

    let entry: ChatMessage

    var body: some View {

        HStack(alignment: .top, spacing: 10) {

            image(for: entry.participant)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 5) {

                if let participant = entry.participant {
                    Text(participant.identity)
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
