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

                    if roomCtx.isStreamHost {
                        PublisherVideoView()
                    } else {
                        SubscriberVideoView()
                    }

                    VStack(alignment: .trailing) {

                        HStack(spacing: 10) {

                            if let lp = room.localParticipant {
                                TextLabel(text: "CanPublish: \(lp.permissions.canPublish ? "YES" : "NO")")
                            }

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

            MessageBarView(moreAction: {
                showingOptionsSheet.toggle()
            })
            .sheet(isPresented: $showingOptionsSheet) {
                OptionsSheet()
            }
            .sheet(isPresented: $showingUsersSheet) {
                ViewersSheet()
            }
        }
    }
}
