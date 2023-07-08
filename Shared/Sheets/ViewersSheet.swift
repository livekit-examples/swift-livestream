import SwiftUI
import LiveKit
import LiveKitComponents

extension Room {

    var typedMetadata: RoomMetadata {

        guard let string = metadata,
              let data = string.data(using: .utf8),
              let obj = try? decoder.decode(RoomMetadata.self, from: data) else {

            return RoomMetadata()
        }

        return obj
    }
}

extension Participant {

    var typedMetadata: ParticipantMetadata {

        guard let string = metadata,
              let data = string.data(using: .utf8),
              let obj = try? decoder.decode(ParticipantMetadata.self, from: data) else {

            return ParticipantMetadata()
        }

        return obj
    }

    var handRaised: Bool {
        typedMetadata.handRaised
    }

    var canPublish: Bool {
        // Considered a host if has publish perms
        permissions.canPublish
    }
}

extension Collection where Element == Participant {

    var sortedByJoinedDate: [Participant] {
        sorted { p1, p2 in
            if p1 is LocalParticipant { return true }
            if p2 is LocalParticipant { return false }
            return (p1.joinedAt ?? Date()) < (p2.joinedAt ?? Date())
        }
    }
}

struct ViewersSheet: View {

    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: Room

    private func filteredByJoinRequests() -> [Participant] {
        room.allParticipants.values.filter { !$0.canPublish && $0.handRaised }
    }

    private func filteredByHosts() -> [Participant] {
        room.allParticipants.values.filter { $0.canPublish }
    }

    private func filteredByViewers() -> [Participant] {
        room.allParticipants.values.filter { !$0.canPublish && !$0.handRaised }
    }

    var body: some View {

        let joinRequests = filteredByJoinRequests()
        let hosts = filteredByHosts()
        let viewers = filteredByViewers()

        ScrollView {
            LazyVStack(spacing: 20) {

                Text("Viewers")
                    .font(.system(size: 25, weight: .bold))
                    .padding()

                /* Join request users */

                if joinRequests.count > 0 {

                    Text("Requests to join")
                        .textCase(.uppercase)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 14, weight: .bold))

                    ForEach(joinRequests) { participant in
                        UserTileView()
                            .environmentObject(participant)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                    }
                }

                if hosts.count > 0 {

                    Text("Hosts")
                        .textCase(.uppercase)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 14, weight: .bold))

                    ForEach(hosts) { participant in
                        UserTileView()
                            .environmentObject(participant)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                    }
                }

                if viewers.count > 0 {

                    Text("Viewers")
                        .textCase(.uppercase)
                        .foregroundColor(Color.gray)
                        .font(.system(size: 14, weight: .bold))

                    ForEach(viewers) { participant in
                        UserTileView()
                            .environmentObject(participant)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                    }
                }

                if let lp = room.localParticipant, !lp.canPublish && !lp.handRaised {

                    Button {
                        roomCtx.raiseHand()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemSymbol: .personBadgePlus)
                            Text("Request to join")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .foregroundColor(Color("Secondary"))
                    }
                }
            }
        }
        .backport.presentationDetents([.medium, .large])
        .backport.presentationDragIndicator(.visible)
        .presentationBackground(.black)
        .padding()
        .frame(minWidth: 300)
    }
}
