import SwiftUI

struct OrbitFont: ViewModifier {

    @Environment(\.sizeCategory) var sizeCategory

    let size: CGFloat
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        content.font(.orbit(size: size, scaledSize: sizeCategory.ratio * size, weight: weight))
    }
}

public extension View {

    /// Sets the Orbit font as a default font for text in this view.
    ///
    /// Handles dynamic type scaling for both system and custom fonts.
    func orbitFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        modifier(OrbitFont(size: size, weight: weight))
    }
}

public extension SwiftUI.Text {

    /// Sets the Orbit font as a default font for text in this view.
    ///
    /// Handles dynamic type scaling for both system and custom fonts.
    func orbitFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        sizeCategory: ContentSizeCategory
    ) -> SwiftUI.Text {
        font(.orbit(size: size, scaledSize: sizeCategory.ratio * size, weight: weight))
    }
}
