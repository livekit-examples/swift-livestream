//
//  ContentView.swift
//  swift-livestream
//
//  Created by Hiroshi Horie on 2023/06/02.
//

import SwiftUI

struct StartView: View {

    @State private var flag1 = true
    @State private var flag2 = true

    var body: some View {
        VStack(alignment: .leading) {
            Text("Start Livestream")
                .font(.system(size: 30, weight: .bold))
            Color.white
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(10)
                .padding(.vertical, 10)
            Text("OPTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)

            Toggle("Enable chat", isOn: $flag1)
            Toggle("Viewers can request to join", isOn: $flag2)

            Text("After going live you’ll acquire a streaming link for sharing with your viewers.")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Button {
                //
            } label: {
                Text("Go live")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderedProminent)
            .background(Color.purple)
            .cornerRadius(10)

        }
        .padding()
    }
}
