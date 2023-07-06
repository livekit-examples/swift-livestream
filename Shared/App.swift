import SwiftUI
import LiveKitComponents

@main
struct swift_livestreamApp: App {

    @StateObject var appCtx = AppContext()

    var body: some Scene {
        WindowGroup {
            ComponentsScope {
                MainView()
            }
            .environmentObject(appCtx)
        }
    }
}
