import SwiftUI

/// Orbit Button size.
public enum ButtonSize {
    case `default`
    case compact
}

struct ButtonSizeKey: EnvironmentKey {
    static let defaultValue = ButtonSize.default
}

public extension EnvironmentValues {

    /// An Orbit `ButtonSize` value stored in a view’s environment.
    var buttonSize: ButtonSize {
        get { self[ButtonSizeKey.self] }
        set { self[ButtonSizeKey.self] = newValue }
    }
}

public extension View {

    /// Set the button size for this view.
    ///
    /// - Parameters:
    ///   - size: A button size that will be used by all components in the view hierarchy.
    func buttonSize(_ size: ButtonSize) -> some View {
        environment(\.buttonSize, size)
    }
}
