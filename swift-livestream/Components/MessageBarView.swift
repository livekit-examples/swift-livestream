import SwiftUI

struct MessageBarView: View {

    @State var text: String = ""

    let moreAction: () -> Void

    var body: some View {
        HStack {
            TextField("Type your message...", text: $text, axis: .vertical)
                .lineLimit(5)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)

            Button {

            } label: {
                Text("Send")
                    .font(.system(size: 14))
            }
            .buttonStyle(.borderedProminent)
            // .tint(Color.purple)
            .cornerRadius(7)

            Button {
                moreAction()
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
            }
        }
        .padding()
    }
}
