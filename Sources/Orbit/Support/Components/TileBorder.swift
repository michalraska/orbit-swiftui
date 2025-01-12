import SwiftUI

public enum TileBorderStyle {
    case none
    case `default`
    /// A border style that visually matches the iOS plain table section appearance in `compact` width environment.
    case iOS
    /// A border with no elevation.
    case plain
}

/// Provides decoration with ``Tile`` appearance.
public struct TileBorderModifier: ViewModifier {

    static let animation: Animation = .easeIn(duration: 0.15)

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.status) var status

    let style: TileBorderStyle
    let isSelected: Bool

    public func body(content: Content) -> some View {
        content
            .clipShape(clipShape)
            .compositingGroup()
            .elevation(elevation, shape: .roundedRectangle(borderRadius: cornerRadius))
            .overlay(border.animation(Self.animation, value: isSelected))
    }

    @ViewBuilder var border: some View {
        switch (style, horizontalSizeClass) {
            case (.none, _):
                EmptyView()
            case (.default, _), (.plain, _), (.iOS, .regular):
                clipShape
                    .strokeBorder(borderColor, lineWidth: borderWidth)
                    .blendMode(isSelected ? .normal : .darken)
            case (.iOS, _):
                VStack {
                    compactSeparatorBorder
                    Spacer()
                    compactSeparatorBorder
                }
        }
    }

    @ViewBuilder var compactSeparatorBorder: some View {
        borderColor
            .frame(height: status == nil ? 1 : BorderWidth.active)
    }

    @ViewBuilder var clipShape: some InsettableShape {
        RoundedRectangle(cornerRadius: cornerRadius)
    }

    var isCompact: Bool {
        (style == .iOS) && horizontalSizeClass == .compact
    }

    var cornerRadius: CGFloat {
        switch (style, horizontalSizeClass) {
            case (.default, _):     return BorderRadius.default
            case (.plain, _):       return BorderRadius.default
            case (.iOS, .regular):  return BorderRadius.default
            case (.iOS, _):         return 0
            case (.none, _):        return 0
        }
    }

    var elevation: Elevation? {
        guard status == .none else {
            return nil
        }

        switch style {
            case .default:
                return .level1
            case .none, .plain, .iOS:
                return nil
        }
    }

    var borderWidth: CGFloat {
        isSelected || status != nil
            ? BorderWidth.active
            : 1
    }

    var borderColor: Color {
        if let status = status {
            return status.color
        }

        if isSelected {
            return .blueNormal
        }

        return showOuterBorder ? .cloudNormal : .clear
    }

    var showOuterBorder: Bool {
        switch style {
            case .iOS, .plain:      return true
            case .none, .default:   return false
        }
    }
}

public extension View {

    /// Decorates content with a border similar to ``Tile`` or ``Card`` appearance using specified style.
    func tileBorder(
        _ style: TileBorderStyle = .default,
        isSelected: Bool = false
    ) -> some View {
        modifier(
            TileBorderModifier(
                style: style,
                isSelected: isSelected
            )
        )
    }
}

// MARK: - Previews
struct TileBorderModifierPreviews: PreviewProvider {

    static var previews: some View {
        PreviewWrapper {
            content
                .tileBorder()

            content
                .tileBorder(.plain)

            content
                .tileBorder(.iOS)

            content
                .tileBorder(.iOS, isSelected: true)

            content
                .background(Color.blueLight)
                .tileBorder()

            content
                .background(Color.blueLight)
                .tileBorder(isSelected: true)

            Group {
                content
                    .background(Color.blueLight)
                    .tileBorder()

                content
                    .background(Color.blueLight)
                    .tileBorder(isSelected: true)
            }
            .status(.critical)

            ListChoice("ListChoice", showSeparator: false, action: {})
                .fixedSize()
                .tileBorder()
        }
        .padding(.medium)
        .previewLayout(.sizeThatFits)
    }

    static var content: some View {
        Text("Content")
            .padding(.medium)
    }
}
