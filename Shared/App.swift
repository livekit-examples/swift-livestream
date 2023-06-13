import SwiftUI
import LiveKitComponents

@main
struct swift_livestreamApp: App {

    var body: some Scene {
        WindowGroup {
            ComponentsScope {
                MainView()
            }
        }
    }
}
