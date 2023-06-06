import SwiftUI

struct TextLabel: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(.purple)
            .cornerRadius(7)
    }
}
