import SwiftUI
import LiveKit
import LiveKitComponents

struct MainView: View {

    @StateObject var roomCtx = RoomContext()

    func viewForStep() -> AnyView {
        switch roomCtx.step {
        case .welcome: return AnyView(WelcomeView())
        case .streamerPrepare: return AnyView(StartPrepareView())
        case .streamerPreview: return AnyView(StartPreviewView())
        case .viewerPrepare: return AnyView(JoinView())
        case .stream: return AnyView(StreamView())
        }
    }

    var body: some View {
        RoomScope(room: roomCtx.room) {
            viewForStep()
                .environmentObject(roomCtx)
                .background(Color.black)
                .foregroundColor(Color.white)
        }
    }
}
