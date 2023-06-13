import SwiftUI
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

struct PublisherVideoView: View {

    var body: some View {

        ZStack(alignment: .topLeading) {

            // Color.white
            LocalCameraVideoView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(7)

            SwitchCameraButton {

            }.padding()
        }
    }
}
