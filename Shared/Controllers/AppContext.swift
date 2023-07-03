import SwiftUI
import LiveKit
import WebRTC

final class AppContext: NSObject, ObservableObject {

    let room = Room()

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

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
    @Published public var events = [StreamEvent]()
    @Published public var canSendMessage: Bool = false
    @Published public var message: String = "" {
        didSet {
            canSendMessage = !message.isEmpty
        }
    }

    override init() {
        super.init()
        room.add(delegate: self)
    }

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

    public func send() {
        Task { @MainActor in
            let event = StreamEvent(type: .message,
                                    identity: room.localParticipant?.identity,
                                    message: message)
            events.append(event)
            message = ""

            guard let jsonData = try? encoder.encode(event) else { return }
            room.localParticipant?.publish(data: jsonData)
        }
    }
}

extension AppContext: RoomDelegate {

    func room(_ room: Room, participantDidJoin participant: RemoteParticipant) {
        Task { @MainActor in
            events.append(StreamEvent(type: .info, message: "\(participant.identity) did join"))
        }
    }

    func room(_ room: Room, participantDidLeave participant: RemoteParticipant) {
        Task { @MainActor in
            events.append(StreamEvent(type: .info, message: "\(participant.identity) left"))
        }
    }

    func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, topic: String) {
        Task { @MainActor in
            guard let event = try? decoder.decode(StreamEvent.self, from: data) else { return }
            events.append(event)
        }
    }
}
