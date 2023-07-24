import SwiftUI

struct BlueButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? color : Color.white)
            .background(configuration.isPressed ? Color.white : color)
            .cornerRadius(6.0)
    }
}

struct StyledButton: View {

    enum Style {
        case normal
        case primary
        case secondary
        case destructive
    }

    enum Size {
        case normal
        case small
    }

    let title: any StringProtocol
    var style: Style = .normal
    var size: Size = .normal
    var isFullWidth = true
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
                        .controlSize(.small)
                }
                Text(title)
                    .font(.system(size: size.toFontSize()))
            }
            .padding(.horizontal, size.toHPadding())
            .padding(.vertical, size.toVPadding())
            .frame(maxWidth: isFullWidth ? .infinity : nil)
        }
        .buttonStyle(BlueButtonStyle(color: style.toColor()))
        .disabled(isBusy || !isEnabled)
        .opacity((isBusy || !isEnabled) ? 0.5 : 1)
        .cornerRadius(6)
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

private extension StyledButton.Size {

    func toFontSize() -> Double {
        switch self {
        case .normal: return 17
        case .small: return 12
        }
    }

    func toVPadding() -> Double {
        switch self {
        case .normal: return 10
        case .small: return 8
        }
    }

    func toHPadding() -> Double {
        switch self {
        case .normal: return 15
        case .small: return 10
        }
    }
}
