import SwiftUI
import LiveKitComponents
import Logging

let logger = Logger(label: "LivestreamExample")
let encoder = JSONEncoder()
let decoder = JSONDecoder()

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
