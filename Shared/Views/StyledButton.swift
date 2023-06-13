import SwiftUI

struct StyledButton: View {

    enum Style {
        case normal
        case primary
        case secondary
        case destructive
    }

    let title: any StringProtocol
    var style: Style = .normal
    var isBusy: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                if isBusy {
                    ProgressView()
                }
                Text(title)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .disabled(isBusy || !isEnabled)
        .foregroundColor(.white.opacity((isBusy || !isEnabled) ? 0.5 : 1))
        .background(style.toColor())
        .cornerRadius(7)
    }
}

private extension StyledButton.Style {

    func toColor() -> Color {
        switch self {
        case .normal: return Color.white.opacity(0.1)
        case .primary: return Color("Primary")
        case .secondary: return Color("Secondary")
        case .destructive: return Color("Destructive")
        }
    }
}
