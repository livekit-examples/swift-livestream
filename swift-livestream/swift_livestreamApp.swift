import SwiftUI

@main
struct swift_livestreamApp: App {

    @StateObject var appCtx = AppContext()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appCtx)
        }
    }
}
