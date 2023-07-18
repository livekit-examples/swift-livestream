import SwiftUI
import SFSafeSymbols

struct TextLabel: View {

    enum Style {
        case normal
        case primary
    }

    let text: String
    var symbol: SFSymbol?
    var style: Style = .normal

    var body: some View {
        HStack(spacing: 5) {
            if let symbol = symbol {
                Image(systemSymbol: symbol)
            }
            Text(text)
        }
        .font(.system(size: 14, weight: .bold))
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .background(style.toColor())
        .cornerRadius(6)
    }
}

extension TextLabel.Style {

    func toColor() -> Color {
        switch self {
        case .normal: return Color.black.opacity(0.6)
        case .primary: return Color("Primary").opacity(0.8)
        }
    }
}
