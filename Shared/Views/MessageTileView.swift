import SwiftUI

struct MessageTileView: View {

    let entry: StreamEvent

    var body: some View {

        HStack(alignment: .top, spacing: 10) {

            Circle()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 5) {

                if let identity = entry.identity {
                    Text(identity)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                }

                Text(entry.message)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
