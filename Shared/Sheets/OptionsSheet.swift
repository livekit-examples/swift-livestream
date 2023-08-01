import SwiftUI
import LiveKit
import LiveKitComponents
import AlertToast

struct OptionsSheet: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    @State var showCopiedToast: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {

                Text("Options")
                    .font(.system(size: 25, weight: .bold))
                    .padding()

                HStack {
                    Text("Livestream code:")
                    Spacer()
                    if let roomName = room.name {
                        StyledButton(style: .secondary,
                                     size: .small,
                                     isFullWidth: false) {
                            #if os(iOS)
                            UIPasteboard.general.string = roomName
                            #elseif os(macOS)
                            let pasteboard = NSPasteboard.general
                            pasteboard.declareTypes([.string], owner: nil)
                            pasteboard.setString(roomName, forType: .string)
                            #endif
                            showCopiedToast = true
                        } label: {
                            Text(roomName)
                        }
                    }
                }

                Spacer()

                StyledButton(style: .destructive,
                             isBusy: roomCtx.endStreamBusy) {

                    roomCtx.leave()
                } label: {
                    Text(roomCtx.isStreamOwner ? "End stream" : "Leave stream")
                }
            }
        }
        .backport.presentationDetents([.medium])
        .backport.presentationDragIndicator(.visible)
        .presentationBackground(.black)
        .padding()
        .frame(minWidth: 300)
        .toast(isPresenting: $showCopiedToast) {
            AlertToast(type: .regular, title: "Copied!")
        }
    }
}
