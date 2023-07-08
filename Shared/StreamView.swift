import SwiftUI
import LiveKit
import SwiftUIBackports

extension Comparable {
    func clamp(minValue: Self, maxValue: Self) -> Self {
        min(max(minValue, self), maxValue)
    }

    func clamp(to range: ClosedRange<Self>) -> Self {
        self.clamp(minValue: range.lowerBound, maxValue: range.upperBound)
    }
}

struct StreamView: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    @State private var showingUsersSheet = false
    @State private var showingOptionsSheet = false

    var body: some View {

        VStack(spacing: 0) {

            GeometryReader { proxy in

                ZStack {

                    if roomCtx.isStreamPublisher {
                        PublisherVideoView()
                    } else {
                        SubscriberVideoView()
                    }

                    VStack(alignment: .trailing) {
                        HStack(spacing: 10) {
                            TextLabel(text: "LIVE", style: .primary)
                            TextLabel(text: "\(room.remoteParticipants.count + 1)", symbol: .eye).onTapGesture {
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
                text: $roomCtx.message,
                sendIsEnabled: $roomCtx.canSendMessage,
                sendAction: {
                    roomCtx.send()
                }, moreAction: {
                    showingOptionsSheet.toggle()
                })
                .sheet(isPresented: $showingOptionsSheet) {
                    VStack {
                        Text("Options")
                            .font(.system(size: 25, weight: .bold))
                            .padding()

                        StyledButton(title: roomCtx.isStreamPublisher ? "End stream" : "Leave stream",
                                     style: .destructive) {

                            roomCtx.leave()
                        }

                        StyledButton(title: "Raise hand",
                                     style: .normal) {

                            roomCtx.raiseHand()
                        }

                    }
                    .backport.presentationDetents([.medium])
                    .backport.presentationDragIndicator(.visible)
                    .presentationBackground(.thinMaterial)
                    .padding()
                }
                .sheet(isPresented: $showingUsersSheet) {
                    Text("Viewers")
                        .font(.system(size: 25, weight: .bold))
                        .padding()

                    UsersListView()
                        .backport.presentationDetents([.medium, .large])
                        .backport.presentationDragIndicator(.visible)
                        .presentationBackground(.black)
                        .padding()
                }
        }
    }
}
