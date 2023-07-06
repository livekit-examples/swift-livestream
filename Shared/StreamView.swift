import SwiftUI
import LiveKit

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
    @EnvironmentObject var room: Room

    @State private var showingUsersSheet = false
    @State private var showingOptionsSheet = false

    var body: some View {

        VStack {

            GeometryReader { proxy in

                ZStack {

                    if appCtx.isPublisher {
                        PublisherVideoView()
                    } else {
                        SubscriberVideoView()
                    }

                    VStack(alignment: .trailing) {
                        HStack {
                            if appCtx.isPublisher {
                                TextLabel(text: "LIVE", style: .primary)
                            }
                            TextLabel(text: "\(room.remoteParticipants.count + 1)").onTapGesture {
                                showingUsersSheet = true
                            }
                        }
                        .padding()

                        Spacer()

                        ZStack {

                            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                           startPoint: .top,
                                           endPoint: .bottom)

                            StreamEventsListView()
                                .mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]),
                                                     startPoint: .bottom,
                                                     endPoint: .top))

                        }
                        .frame(height: proxy.size.height * 0.4)
                    }
                }
            }

            MessageBarView(
                text: $appCtx.message,
                sendIsEnabled: $appCtx.canSendMessage,
                sendAction: {
                    appCtx.send()
                }, moreAction: {
                    showingOptionsSheet.toggle()
                })
                .sheet(isPresented: $showingOptionsSheet) {
                    VStack {
                        Text("Options")
                            .font(.system(size: 25, weight: .bold))

                        StyledButton(title: appCtx.isPublisher ? "End stream" : "Leave stream",
                                     style: .destructive) {

                            appCtx.leave()
                        }

                        StyledButton(title: "Raise hand",
                                     style: .normal) {

                            appCtx.raiseHand()
                        }

                    }
                    .padding()
                }
                .sheet(isPresented: $showingUsersSheet) {
                    UsersListView()
                        .padding()
                }
        }
    }
}
