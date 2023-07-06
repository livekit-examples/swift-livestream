import SwiftUI

struct MessageBarView: View {

    @Binding var text: String
    @Binding var sendIsEnabled: Bool

    //    let showJoinButton: Bool

    let sendAction: () -> Void
    let moreAction: () -> Void
    //    let joinAction: () -> Void

    var body: some View {
        HStack {
            TextField("Type your message...", text: $text)
                .lineLimit(5)
                .font(.system(size: 14))
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
            }

            //            if showJoinButton {
            //
            //                Button {
            //                    moreAction()
            //                } label: {
            //                    Image(systemName: "ellipsis")
            //                        .rotationEffect(.degrees(90))
            //                }
            //
            //            }
        }
        .padding()
    }
}
