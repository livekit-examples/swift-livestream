import SwiftUI

struct MessageTileView: View {

    var body: some View {

        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 5) {
                Text("SomeUser1987")
                    .font(.system(size: 14))
                    .fontWeight(.bold)

                Text("Hello this is some test string. Hello this is some test string. Hello this is some test string. Hello this is some test string.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
        }
    }
}
