import SwiftUI

struct StreamEventsListView: View {

    @EnvironmentObject var appCtx: AppContext

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer()
                    .frame(height: 50)
                LazyVStack(spacing: 12) {
                    ForEach(appCtx.events) { entry in
                        StreamEventTileView(entry: entry)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)

                    }
                    .onChange(of: appCtx.events.count) { _ in
                        withAnimation {
                            if let lastId = appCtx.events.last?.id {
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
