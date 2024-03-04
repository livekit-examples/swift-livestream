/*
 * Copyright 2024 LiveKit
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import LiveKit
import Logging
import SwiftUI

final class RoomContext: NSObject, ObservableObject {
    static let chatTopic = "lk-chat-topic"

    let api = API(apiBaseURLString: "https://livestream.livekit.io/")
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
    @Published public var inviteBusy: Set<Participant.Identity> = []

    @Published public private(set) var step: Step = .welcome
    @Published public var events = [ChatMessage]()

    @Published public var message: String = ""

    @Published public var roomName: String = ""
    @Published public var identity: String = ""

    @Published public var enableChat: Bool = true
    @Published public var viewersCanRequestToJoin: Bool = true

    // Computed helpers
    public var isStreamOwner: Bool {
        room.typedMetadata.creatorIdentity == room.localParticipant.identity?.stringValue
    }

    public var isStreamHost: Bool {
        room.localParticipant.canPublish
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
                guard await LiveKitSDK.ensureDeviceAccess(for: [.video, .audio]) else {
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

                try await room.connect(url: res.connectionDetails.wsURL, token: res.connectionDetails.token)
                Task { @MainActor in
                    self.step = .stream

                    // Separate attempt to publish
                    Task {
                        do {
                            try await room.localParticipant.setCamera(enabled: true)
                            try await room.localParticipant.setMicrophone(enabled: true)
                        } catch {
                            logger.error("Failed to publish, error: \(error)")
                        }
                    }
                }
                logger.info("Connected")
            } catch let publishError {
                await room.disconnect()
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

                try await room.connect(url: res.connectionDetails.wsURL, token: res.connectionDetails.token)
                Task { @MainActor in
                    self.step = .stream
                }
                logger.info("Connected")
            } catch {
                await room.disconnect()
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
                    await room.disconnect()
                }
            } catch {
                logger.error("Failed to leave \(error)")
            }
        }
    }

    public func inviteToStage(identity: Participant.Identity) {
        Task {
            Task { @MainActor in inviteBusy.insert(identity) }
            defer { Task { @MainActor in inviteBusy.remove(identity) } }

            do {
                logger.info("Invite to stage \(identity)...")
                try await api.inviteToStage(identity: identity)
            } catch {
                logger.error("Failed to invite to stage \(error)")
            }
        }
    }

    public func removeFromStage(identity: Participant.Identity? = nil) {
        Task {
            do {
                logger.info("Removing from stage \(String(describing: identity))...")
                try await api.removeFromStage(identity: identity)
            } catch {
                logger.error("Failed to remove from stage \(error)")
            }
        }
    }

    public func reject(userId _: String) {
        Task {
            do {
                logger.info("Raising hand...")
                try await api.raiseHand()
            } catch {
                logger.error("Failed to raise hand \(error)")
            }
        }
    }

    public func raiseHand() {
        Task {
            do {
                logger.info("Raising hand...")
                try await api.raiseHand()
            } catch {
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
            try await room.localParticipant.publish(data: jsonData, options: DataPublishOptions(topic: RoomContext.chatTopic))
        }
    }
}

extension RoomContext: RoomDelegate {
    func room(_: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String) {
        // Check if chat topic
        guard topic == RoomContext.chatTopic else { return }

        Task { @MainActor in
            guard var chatMessage = try? decoder.decode(ChatMessage.self, from: data) else { return }
            chatMessage.participant = participant
            events.append(chatMessage)
        }
    }

    func room(_: Room, didUpdateConnectionState connectionState: ConnectionState, from oldValue: ConnectionState) {
        if case .disconnected = connectionState,
           case .connected = oldValue
        {
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

    func room(_: Room, participant: Participant, didUpdatePermissions _: ParticipantPermissions) {
        if let participant = participant as? LocalParticipant,
           participant.canPublish
        {
            // Separate attempt to publish
            Task {
                do {
                    // Ensure permissions...
                    guard await LiveKitSDK.ensureDeviceAccess(for: [.video, .audio]) else {
                        // Both .video and .audio device permissions are required...
                        throw LivestreamError.permissions
                    }

                    try await participant.setCamera(enabled: true)
                    try await participant.setMicrophone(enabled: true)
                } catch {
                    logger.error("Failed to publish, error: \(error)")
                }
            }
        }
    }
}
