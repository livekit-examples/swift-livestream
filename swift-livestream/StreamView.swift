import SwiftUI

extension Comparable {
    func clamp(minValue: Self, maxValue: Self) -> Self {
        min(max(minValue, self), maxValue)
    }

    func clamp(to range: ClosedRange<Self>) -> Self {
        self.clamp(minValue: range.lowerBound, maxValue: range.upperBound)
    }
}

struct MessagesView: View {

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

        .coordinateSpace(name: "scroll")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UsersView: View {

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
        .coordinateSpace(name: "scroll")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StreamView: View {

    @EnvironmentObject var appCtx: AppContext

    @State private var showingMoreMenu = false

    var body: some View {

        VStack {

            GeometryReader { proxy in

                ZStack {
                    PublisherVideoView()

                    VStack(alignment: .trailing) {
                        HStack {
                            TextLabel(text: "LIVE")
                            TextLabel(text: "1.2K")
                        }
                        .padding()

                        Spacer()

                        ZStack {

                            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                           startPoint: .top,
                                           endPoint: .bottom)

                            MessagesView()
                                .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]),
                                                     startPoint: .bottom,
                                                     endPoint: .top))

                        }
                        .frame(height: proxy.size.height * 0.4)
                    }
                }
            }

            MessageBarView {
                showingMoreMenu.toggle()
            }
            .sheet(isPresented: $showingMoreMenu) {
                UsersView()
                    .padding(.top, 30)
                    .presentationDetents([.medium])
            }
        }
    }
}
