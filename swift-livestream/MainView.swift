import SwiftUI

struct MainView: View {

    @EnvironmentObject var appCtx: AppContext

    func viewForStep() -> AnyView {
        switch appCtx.step {
        case .start: return AnyView(StartView())
        case .stream: return AnyView(StreamView())
        }
    }

    var body: some View {
        viewForStep()
            .background(Color.black)
            .foregroundColor(Color.white)
    }
}
