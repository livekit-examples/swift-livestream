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
import SwiftUI

struct StreamerPrepareView: View {
    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    @State private var showDialog = false
    @State private var disconnectError: LiveKitError?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))

            PublisherVideoPreview()
                .padding(.vertical, 10)

            StyledTextField(title: "Your name",
                            placeholder: "Type your name...",
                            text: $roomCtx.identity)

            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $roomCtx.enableChat)
            Toggle("Viewers can request to join", isOn: $roomCtx.viewersCanRequestToJoin)

            Spacer()

            StyledButton(style: .primary,
                         isBusy: roomCtx.connectBusy,
                         isEnabled: roomCtx.canGoLive)
            {
                roomCtx.startPublisher()
            } label: {
                Text("Go live")
            }

            StyledButton {
                roomCtx.backToWelcome()
            } label: {
                Text("Back")
            }
        }
        .padding()
        .onChange(of: room.connectionState) { _ in
            if case .disconnected = room.connectionState {
                disconnectError = room.disconnectError
                showDialog = true
            }
        }
        .alert(isPresented: $showDialog) {
            Alert(title: Text("Disconnected"),
                  message: Text("Reason: " + (disconnectError != nil
                          ? String(describing: disconnectError!)
                          : "Unknown")))
        }
    }
}
