import SwiftUI

struct UsersListView: View {

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(0..<100) { _ in
                    UserTileView()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
