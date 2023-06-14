import SwiftUI

extension Comparable {
    func clamp(minValue: Self, maxValue: Self) -> Self {
        min(max(minValue, self), maxValue)
    }

    func clamp(to range: ClosedRange<Self>) -> Self {
        self.clamp(minValue: range.lowerBound, maxValue: range.upperBound)
    }
}

struct StreamView: View {

    @EnvironmentObject var appCtx: AppContext

    @State private var showingMoreMenu = false

    let isPublisher: Bool

    init(isPublisher: Bool = false) {
        self.isPublisher = isPublisher
    }

    var body: some View {

        VStack {

            GeometryReader { proxy in

                ZStack {

                    if isPublisher {
                        PublisherVideoView()
                    } else {
                        SubscriberVideoView()
                    }

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

                            MessagesListView()
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
                UsersListView()
                    .padding(.top, 30)
                // .presentationDetents([.medium])
            }
        }
    }
}
