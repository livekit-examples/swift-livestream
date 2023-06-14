import SwiftUI

struct TextLabel: View {

    enum Style {
        case normal
        case primary
    }

    let text: String
    var style: Style = .normal

    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(style.toColor())
            .cornerRadius(7)
    }
}

extension TextLabel.Style {

    func toColor() -> Color {
        switch self {
        case .normal: return Color.black.opacity(0.4)
        case .primary: return Color("Primary")
        }
    }
}
