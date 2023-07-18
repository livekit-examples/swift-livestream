import SwiftUI
import LiveKit
import LiveKitComponents

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }
}

struct PublisherVideoPreview: View {

    var body: some View {

        ZStack(alignment: .topLeading) {

            LocalCameraPreview()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(6)

            SwitchCameraButton {

            }.padding()
        }
    }
}

struct PublisherVideoView: View {

    var body: some View {

        ZStack(alignment: .topLeading) {

            LocalCameraVideoView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(6)

            SwitchCameraButton {

            }.padding()
        }
    }
}

struct SubscriberVideoView: View {

    @EnvironmentObject var room: Room
    @EnvironmentObject var ui: UIPreference

    var body: some View {

        ZStack(alignment: .topLeading) {

            GeometryReader { geometry in

                ZStack {
                    ui.videoDisabledView(geometry: geometry)

                    if let firstRemoteVideoTrack = room.remoteParticipants.values.map({ $0.firstCameraVideoTrack })
                        .compactMap({ $0 }).first {
                        SwiftUIVideoView(firstRemoteVideoTrack)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(6)

            SwitchCameraButton {

            }.padding()
        }
    }
}
