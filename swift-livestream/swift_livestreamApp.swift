//
//  swift_livestreamApp.swift
//  swift-livestream
//
//  Created by Hiroshi Horie on 2023/06/02.
//

import SwiftUI

@main
struct swift_livestreamApp: App {

    @StateObject var appCtx = AppContext()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCtx)
        }
    }
}
