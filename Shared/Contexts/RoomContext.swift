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
        case viewerPrepare
        case stream
    }

    public var canGoLive: Bool {
        !(identity.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty
    }

    public var canJoinLive: Bool {
        !(identity.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty
            && !(roomName.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty
    }

    public var canSendMessage: Bool {
        !(message.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty
    }

    // Network busy states
    @Published public var connectBusy = false
    @Published public var endStreamBusy = false
    @Published public var inviteBusy: Set<String> = []

    @Published public private(set) var step: Step = .welcome
    @Published public var events = [ChatMessage]()

    @Published public var message: String = ""

    @Published public var roomName: String = ""
    @Published public var identity: String = ""

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
                // Ensure permissions...
                guard await LiveKit.ensureDeviceAccess(for: [.video, .audio]) else {
                    // Both .video and .audio device permissions are required...
                    throw LivestreamError.permissions
                }

                logger.debug("Requesting create room...")

                let meta = CreateStreamRequest.Metadata(creatorIdentity: identity.trimmingCharacters(in: .whitespacesAndNewlines),
                                                        enableChat: enableChat,
                                                        allowParticipant: viewersCanRequestToJoin)

                let req = CreateStreamRequest(roomName: "", metadata: meta)
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

                let req = JoinStreamRequest(roomName: roomName.trimmingCharacters(in: .whitespacesAndNewlines),
                                            identity: identity.trimmingCharacters(in: .whitespacesAndNewlines))
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
            let trimmedMessage = self.message.trimmingCharacters(in: .whitespacesAndNewlines)
            let chatMessage = ChatMessage(timestamp: 0,
                                          message: trimmedMessage,
                                          participant: self.room.localParticipant)

            events.append(chatMessage)
            message = ""

            guard let jsonData = try? encoder.encode(chatMessage) else { return }
            room.localParticipant?.publish(data: jsonData)
        }
    }
}

extension RoomContext: RoomDelegate {

    func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, topic: String) {
        Task { @MainActor in
            guard var chatMessage = try? decoder.decode(ChatMessage.self, from: data) else { return }
            chatMessage.participant = participant
            events.append(chatMessage)
        }
    }

    func room(_ room: Room, didUpdate metadata: String?) {
        // logger.info("room metadata: \()")
    }

    func room(_ room: Room, participant: Participant, didUpdate metadata: String?) {
        logger.info("participant metadata: \(participant.typedMetadata)")
    }

    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {

        if case .disconnected = connectionState,
           case .connected = oldValue {
            Task { @MainActor in
                self.step = .welcome
            }

            logger.debug("Did disconnect")
        }

        if case .disconnected = connectionState {
            // Reset state when disconnected
            api.reset()
            Task { @MainActor in
                message = ""
                events = []
            }
        }
    }

    func room(_ room: Room, participant: Participant, didUpdate permissions: ParticipantPermissions) {

        if let participant = participant as? LocalParticipant,
           participant.canPublish {

            // Separate attempt to publish
            Task {
                do {
                    // Ensure permissions...
                    guard await LiveKit.ensureDeviceAccess(for: [.video, .audio]) else {
                        // Both .video and .audio device permissions are required...
                        throw LivestreamError.permissions
                    }

                    try await participant.setCamera(enabled: true)
                    try await participant.setMicrophone(enabled: true)
                } catch let error {
                    logger.error("Failed to publish, error: \(error)")
                }
            }
        }
    }
}
