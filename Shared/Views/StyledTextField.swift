import SwiftUI

struct StyledTextField: View {

    enum Style {
        case normal
        case primary
        case secondary
        case destructive
    }

    let title: any StringProtocol
    @Binding var text: String
    var style: Style = .normal

    var body: some View {

        VStack(alignment: .leading, spacing: 10.0) {
            Text(title)
                .fontWeight(.bold)

            TextField("Type your message...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                // TODO: add iOS unique view modifiers
                // #if os(iOS)
                // .autocapitalization(.none)
                // .keyboardType(type.toiOSType())
                // #endif
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0)
                            .strokeBorder(Color.white.opacity(0.3),
                                          style: StrokeStyle(lineWidth: 1.0)))
        }.frame(maxWidth: .infinity)
    }
}

// private extension StyledButton.Style {
//
//    func toColor() -> Color {
//        switch self {
//        case .normal: return Color.white.opacity(0.1)
//        case .primary: return Color("Primary")
//        case .secondary: return Color("Secondary")
//        case .destructive: return Color("Destructive")
//        }
//    }
// }
