import SwiftUI
import LiveKit
import WebRTC
import Logging

final class RoomContext: NSObject, ObservableObject {

    let api = API(apiBaseURLString: "https://livestream-mobile-backend.vercel.app/")
    let room = Room()

    enum Step {
        case welcome
        case streamerPrepare
        case streamerPreview
        case viewerPrepare
        case stream
    }

    // Network busy states
    @Published public var connectBusy = false
    @Published public var endStreamBusy = false
    @Published public var inviteBusy: Set<String> = []

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

    // Computed helpers
    public var isStreamOwner: Bool {
        room.typedMetadata.creatorIdentity == room.localParticipant?.identity
    }

    public var isStreamHost: Bool {
        room.localParticipant?.canPublish ?? false
    }

    override init() {
        super.init()
        room.add(delegate: self)
        logger.info("RoomContext created")
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
                logger.debug("Requesting create room...")

                let meta = CreateStreamRequest.Metadata(creatorIdentity: identity,
                                                        enableChat: enableChat,
                                                        allowParticipant: viewersCanRequestToJoin)

                let req = CreateStreamRequest(roomName: roomName, metadata: meta)
                let res = try await api.createStream(req)

                logger.debug("Connecting to room... \(res.connectionDetails)")

                try await room.connect(res.connectionDetails.wsURL, res.connectionDetails.token)
                Task { @MainActor in
                    self.step = .stream

                    // Separate attempt to publish
                    Task {
                        do {
                            try await room.localParticipant?.setCamera(enabled: true)
                            try await room.localParticipant?.setMicrophone(enabled: true)
                        } catch let error {
                            logger.error("Failed to publish, error: \(error)")
                        }
                    }
                }
                logger.info("Connected")
            } catch let publishError {
                try await room.disconnect()
                logger.error("Failed to create room, error: \(publishError)")
            }
        }
    }

    public func join() {
        Task {
            Task { @MainActor in connectBusy = true }
            defer { Task { @MainActor in connectBusy = false } }

            do {
                logger.debug("Requesting create room...")

                let req = JoinStreamRequest(roomName: roomName, identity: identity)
                let res = try await api.joinStream(req)

                logger.debug("Connecting to room... \(res.connectionDetails)")

                try await room.connect(res.connectionDetails.wsURL, res.connectionDetails.token)
                Task { @MainActor in
                    self.step = .stream
                }
                logger.info("Connected")
            } catch let error {
                try await room.disconnect()
                logger.error("Failed to join room \(error)")
            }
        }
    }

    public func leave() {
        Task {
            Task { @MainActor in endStreamBusy = true }
            defer { Task { @MainActor in endStreamBusy = false } }

            do {
                logger.info("Leaving...")
                if isStreamOwner {
                    try await api.stopStream()
                } else {
                    logger.info("Disconnecting...")
                    try await room.disconnect()
                }
            } catch let error {
                logger.error("Failed to leave \(error)")
            }
        }
    }

    public func inviteToStage(identity: String) {
        Task {
            Task { @MainActor in inviteBusy.insert(identity) }
            defer { Task { @MainActor in inviteBusy.remove(identity) } }

            do {
                logger.info("Invite to stage \(identity)...")
                try await api.inviteToStage(identity: identity)
            } catch let error {
                logger.error("Failed to invite to stage \(error)")
            }
        }
    }

    public func removeFromStage(identity: String? = nil) {
        Task {
            do {
                logger.info("Removing from stage \(String(describing: identity))...")
                try await api.removeFromStage(identity: identity)
            } catch let error {
                logger.error("Failed to remove from stage \(error)")
            }
        }
    }

    public func reject(userId: String) {
        Task {
            do {
                logger.info("Raising hand...")
                try await api.raiseHand()
            } catch let error {
                logger.error("Failed to raise hand \(error)")
            }
        }
    }

    public func raiseHand() {
        Task {
            do {
                logger.info("Raising hand...")
                try await api.raiseHand()
            } catch let error {
                logger.error("Failed to raise hand \(error)")
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

extension RoomContext: RoomDelegate {

    func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, topic: String) {
        Task { @MainActor in
            guard let event = try? decoder.decode(StreamEvent.self, from: data) else { return }
            events.append(event)
        }
    }

    func room(_ room: Room, didUpdate metadata: String?) {
        // logger.info("room metadata: \()")
    }

    func room(_ room: Room, participant: Participant, didUpdate metadata: String?) {
        logger.info("participant metadata: \(participant.typedMetadata)")
    }

    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {

        if case .disconnected(let reason) = connectionState,
           case .connected = oldValue {
            Task { @MainActor in
                self.step = .welcome
            }

            logger.debug("Did disconnect")
        }

        if case .disconnected(let reason) = connectionState {
            api.reset()
        }
    }
}
