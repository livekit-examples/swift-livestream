import SwiftUI

struct MessagesListView: View {

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(0..<100) { _ in
                    MessageTileView()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 5)

                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
