import SwiftUI
import LiveKit
import WebRTC

final class AppContext: ObservableObject {

    let room = Room()

    @AppStorage("url") var url = ""
    @AppStorage("token") var token = ""

    enum Step {
        case welcome
        case streamerPrepare
        case streamerPreview
        case viewerPrepare
        case publisherStream
        case subscriberStream
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
            self.step = .streamerPrepare
        }
    }

    public func startPublisher() {
        Task {
            do {
                try await room.connect(url, token)
                try await room.localParticipant?.setCamera(enabled: true)
                Task { @MainActor in
                    self.step = .publisherStream
                }
            } catch {
                try await room.disconnect()
            }
        }
    }

    public func join() {
        Task {
            do {
                try await room.connect(url, token)
                Task { @MainActor in
                    self.step = .subscriberStream
                }
            } catch {
                try await room.disconnect()
            }
        }
    }

    public func leave() {
        Task {
            try await room.disconnect()
            Task { @MainActor in
                self.step = .welcome
            }
        }
    }
}
