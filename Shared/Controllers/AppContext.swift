import SwiftUI
import LiveKit
import WebRTC

final class AppContext: NSObject, ObservableObject {

    let api = API(apiBaseURLString: "https://livestream-mobile-backend.vercel.app/")
    let room = Room()

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    enum Step {
        case welcome
        case streamerPrepare
        case streamerPreview
        case viewerPrepare
        case publisherStream
        case subscriberStream
    }

    @Published public var connectBusy = false
    @Published public var isPublisher = false

    @Published public private(set) var step: Step = .welcome
    @Published public var events = [StreamEvent]()
    @Published public var canSendMessage: Bool = false
    @Published public var message: String = "" {
        didSet {
            canSendMessage = !message.isEmpty
        }
    }

    @Published public var identity: String = ""
    @Published public var roomName: String = ""

    @Published public var enableChat: Bool = true
    @Published public var viewersCanRequestToJoin: Bool = true

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
            Task { @MainActor in connectBusy = true }
            defer { Task { @MainActor in connectBusy = false } }

            do {
                print("Requesting create room...")
                let meta = CreateStreamRequest.Metadata(creatorIdentity: identity,
                                                        enableChat: enableChat,
                                                        allowParticipant: viewersCanRequestToJoin)

                let req = CreateStreamRequest(roomName: roomName, metadata: meta)
                let res = try await api.createStream(req)

                print("Connecting to room... \(res.connectionDetails)")

                try await room.connect(res.connectionDetails.wsURL, res.connectionDetails.token)
                try await room.localParticipant?.setCamera(enabled: true)
                Task { @MainActor in
                    self.step = .publisherStream
                    self.isPublisher = true
                }
            } catch {
                try await room.disconnect()
            }
        }
    }

    public func join() {
        Task {
            Task { @MainActor in connectBusy = true }
            defer { Task { @MainActor in connectBusy = false } }

            do {
                print("Requesting create room...")
                let meta = CreateStreamRequest.Metadata(creatorIdentity: identity,
                                                        enableChat: enableChat,
                                                        allowParticipant: viewersCanRequestToJoin)

                let req = CreateStreamRequest(roomName: roomName, metadata: meta)
                let res = try await api.createStream(req)

                print("Connecting to room... \(res.connectionDetails)")

                try await room.connect(res.connectionDetails.wsURL, res.connectionDetails.token)
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
            do {
                print("Leaving...")
                if isPublisher {
                    try await api.stopStream()
                } else {
                    print("Disconnecting...")
                    try await room.disconnect()
                }
            } catch let error {
                print("Failed to leave \(error)")
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

    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {

        if case .disconnected(let reason) = connectionState,
           case .connected = oldValue {
            Task { @MainActor in
                self.step = .welcome
            }

            print("Did disconnect")
        }

        if case .disconnected(let reason) = connectionState {
            Task { @MainActor in
                self.isPublisher = false
            }
            api.reset()
        }
    }
}
