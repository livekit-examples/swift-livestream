import SwiftUI
import LiveKitComponents

struct MainView: View {

    @StateObject var appCtx = AppContext()

    func viewForStep() -> AnyView {
        switch appCtx.step {
        case .welcome: return AnyView(WelcomeView())
        case .startPrepare: return AnyView(StartPrepareView())
        case .startPreview: return AnyView(StartPreviewView())
        case .stream: return AnyView(StreamView())
        default: return AnyView(EmptyView())
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
