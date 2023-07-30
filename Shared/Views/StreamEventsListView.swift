import SwiftUI

struct StreamEventsListView: View {

    @EnvironmentObject var roomCtx: RoomContext

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer()
                    .frame(height: 50)
                LazyVStack(spacing: 12) {
                    ForEach(roomCtx.events, id: \.self) { entry in
                        StreamEventTileView(entry: entry)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)

                    }
                    .onChange(of: roomCtx.events.count) { _ in
                        withAnimation {
                            if let lastId = roomCtx.events.last {
                                proxy.scrollTo(lastId)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
