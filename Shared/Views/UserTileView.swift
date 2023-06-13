import SwiftUI

struct UserTileView: View {

    var body: some View {

        HStack(alignment: .center, spacing: 10) {
            Circle()
                .frame(width: 30, height: 30)

            Text("SomeUser1987")
                .font(.system(size: 14))
                .fontWeight(.bold)

            Spacer()
        }
    }
}
