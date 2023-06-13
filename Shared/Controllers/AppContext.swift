import SwiftUI
import LiveKit
import WebRTC

final class AppContext: ObservableObject {

    let room = Room()

    @AppStorage("url") var url = ""
    @AppStorage("token") var token = ""

    enum Step {
        case welcome
        case startPrepare
        case startPreview
        case join
        case stream
    }

    @Published public private(set) var step: Step = .welcome

    public func set(step: Step) {
        self.step = step
    }

    public func backToWelcome() {
        Task { @MainActor in
            self.step = .welcome
        }
    }

    public func backToPrepare() {
        Task { @MainActor in
            self.step = .startPrepare
        }
    }

    public func startPublisher() {
        Task {
            try await room.connect(url, token)
            try await room.localParticipant?.setCamera(enabled: true)
            Task { @MainActor in
                self.step = .stream
            }
        }
    }
}
