import SwiftUI

struct SwitchCameraButton: View {

    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.black.opacity(0.7))
        .cornerRadius(7)
    }
}
