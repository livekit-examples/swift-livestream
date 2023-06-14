import SwiftUI
import LiveKit
import LiveKitComponents

struct MainView: View {

    @StateObject var appCtx = AppContext()

    func viewForStep() -> AnyView {
        switch appCtx.step {
        case .welcome: return AnyView(WelcomeView())
        case .streamerPrepare: return AnyView(StartPrepareView())
        case .streamerPreview: return AnyView(StartPreviewView())
        case .viewerPrepare: return AnyView(JoinView())
        case .publisherStream: return AnyView(StreamView(isPublisher: true))
        case .subscriberStream: return AnyView(StreamView(isPublisher: false))
        }
    }

    var body: some View {
        RoomScope(room: appCtx.room) {
            viewForStep()
                .environmentObject(appCtx)
                .background(Color.black)
                .foregroundColor(Color.white)
        }
    }
}
