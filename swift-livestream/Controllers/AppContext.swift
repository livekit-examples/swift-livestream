import SwiftUI
import LiveKit
import WebRTC

final class AppContext: ObservableObject {

    enum Step {
        case start
        case stream
    }

    @Published public private(set) var step: Step = .stream

    public func set(step: Step) {
        self.step = step
    }
}
