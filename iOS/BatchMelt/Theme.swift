import SwiftUI

/// Batch Melt - Metal Casting Log's own palette: distinct from every sibling app in the portfolio.
enum BMTheme {
    static let backdrop = Color(red: 0.957, green: 0.941, blue: 0.918)
    static let card = Color.white

    static let ink = Color(red: 0.137, green: 0.106, blue: 0.086)
    static let inkFaded = Color(red: 0.137, green: 0.106, blue: 0.086).opacity(0.56)

    static let accent = Color(red: 0.78, green: 0.353, blue: 0.169)
    static let accentDeep = Color(red: 0.7000000000000001, green: 0.27299999999999996, blue: 0.08900000000000001)
    static let accent2 = Color(red: 0.243, green: 0.243, blue: 0.267)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BMDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BMDismissKeyboardOnTap())
    }
}

enum BMHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
