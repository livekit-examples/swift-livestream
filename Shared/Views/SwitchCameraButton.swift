import SwiftUI
import LiveKit

struct SwitchCameraButton: View {

    @EnvironmentObject var room: Room
    @EnvironmentObject var participant: Participant

    var body: some View {

        if participant is LocalParticipant, CameraCapturer.canSwitchPosition() {

            StyledButton(style: .clear,
                         isFullWidth: false) {
                Task {
                    if let track = participant.firstCameraVideoTrack as? LocalVideoTrack,
                       let cameraCapturer = track.capturer as? CameraCapturer {
                        try await cameraCapturer.switchCameraPosition()
                    }
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .cornerRadius(6)
        }
    }
}
