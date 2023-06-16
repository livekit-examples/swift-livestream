import SwiftUI

struct MessageBarView: View {

    @Binding var text: String

    let sendAction: () -> Void
    let moreAction: () -> Void

    var body: some View {
        HStack {
            TextField("Type your message...", text: $text)
                .lineLimit(5)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)

            StyledButton(title: "Send",
                         style: .secondary,
                         size: .small,
                         isFullWidth: false) {
                sendAction()
            }

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
