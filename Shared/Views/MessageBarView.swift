import SwiftUI

struct MessageBarView: View {

    @State var text: String = ""

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
