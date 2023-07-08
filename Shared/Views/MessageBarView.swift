import SwiftUI

struct MessageBarView: View {

    @Binding var text: String
    @Binding var sendIsEnabled: Bool

    // let showJoinButton: Bool

    let sendAction: () -> Void
    let moreAction: () -> Void
    // let joinAction: () -> Void

    var body: some View {
        HStack {
            TextField("Type your message...", text: $text, axis: .vertical)
                .lineLimit(5)
                .font(.system(size: 14))
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(5)
                .frame(maxWidth: .infinity)

            StyledButton(title: "Send",
                         style: .secondary,
                         size: .small,
                         isFullWidth: false,
                         isEnabled: sendIsEnabled) {
                sendAction()
            }

            Button {
                moreAction()
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(Color("Secondary"))
            }

            // if showJoinButton {
            //
            //     Button {
            //         moreAction()
            //     } label: {
            //         Image(systemName: "ellipsis")
            //             .rotationEffect(.degrees(90))
            //     }
            //
            // }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
    }
}
