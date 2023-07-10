import SwiftUI
import LiveKit
import LiveKitComponents

struct OptionsSheet: View {

    @EnvironmentObject var roomCtx: RoomContext

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {

                Text("Options")
                    .font(.system(size: 25, weight: .bold))
                    .padding()

                StyledButton(title: roomCtx.isStreamHost ? "End stream" : "Leave stream",
                             style: .destructive,
                             isBusy: roomCtx.endStreamBusy) {

                    roomCtx.leave()
                }
            }
        }
        .backport.presentationDetents([.medium])
        .backport.presentationDragIndicator(.visible)
        .presentationBackground(.black)
        .padding()
        .frame(minWidth: 300)
    }
}
