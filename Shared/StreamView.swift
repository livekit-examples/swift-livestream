import SwiftUI
import LiveKit
import LiveKitComponents
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

    var hasNotification: Bool {
        if roomCtx.isStreamOwner {
            return room.remoteParticipants.values.filter({ $0.handRaised && !$0.canPublish }).count > 0
        } else {
            guard let lp = room.localParticipant else { return false }
            return lp.invited && !lp.canPublish
        }
    }

    var body: some View {

        VStack(spacing: 0) {

            GeometryReader { proxy in

                ZStack {

                    VStack {
                        ForEachParticipant(filter: .canPublishMedia) { _ in
                            ParticipantView()
                                .background(Color(.darkGray))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(5)
                        }
                    }

                    VStack(alignment: .trailing) {

                        HStack(spacing: 10) {

                            TextLabel(text: "LIVE", style: .primary)

                            ZStack(alignment: .topLeading) {
                                TextLabel(text: "\(room.remoteParticipants.count + 1)", symbol: .eye).onTapGesture {
                                    showingUsersSheet = true
                                }

                                if hasNotification {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: -3, y: -3)
                                }
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
                .onTapGesture {
                    self.hideKeyboard()
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
        .onChange(of: hasNotification, perform: { newValue in
            if newValue {
                showingUsersSheet = true
            }
        })
    }
}
