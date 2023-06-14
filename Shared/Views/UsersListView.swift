import SwiftUI
import LiveKitComponents

struct UsersListView: View {

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEachParticipant { _ in
                    UserTileView()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                }
            }
        }
    }
}
