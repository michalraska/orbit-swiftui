import SwiftUI

/// Presents users with short, relevant information.
///
/// Badges are indicators of static information.
/// They can be updated when a status changes, but they should not be actionable.
///
/// - Note: [Orbit definition](https://orbit.kiwi/components/badge/)
public struct Badge<LeadingIcon: View, TrailingIcon: View>: View {

    @Environment(\.status) private var status
    @Environment(\.sizeCategory) private var sizeCategory

    private let label: String
    private let leadingIcon: LeadingIcon
    private let trailingIcon: TrailingIcon
    private let style: BadgeStyle

    public var body: some View {
        if isEmpty == false {
            HStack(spacing: .xxSmall) {
                leadingIcon
                    .iconSize(.small)
                    .font(.system(size: Icon.Size.small.value))
                    .foregroundColor(labelColor)

                Text(label)
                    .textSize(.small)
                    .fontWeight(.medium)
                    .textLinkColor(.custom(labelColor))
                    .frame(minWidth: minTextWidth)

                trailingIcon
                    .iconSize(.small)
                    .font(.system(size: Icon.Size.small.value))
                    .foregroundColor(labelColor)
            }
            .textColor(labelColor)
            .padding(.vertical, .xxSmall) // = 24 height @ normal size
            .padding(.horizontal, .xSmall)
            .background(
                background
                    .clipShape(shape)
            )
        }
    }

    @ViewBuilder var background: some View {
        switch style {
            case .light:                                Color.whiteDarker
            case .lightInverted:                        Color.inkDark
            case .neutral:                              Color.cloudLight
            case .status(let status, true):             (status ?? defaultStatus).color
            case .status(let status, false):            (status ?? defaultStatus).lightColor
            case .custom(_, _, let backgroundColor):    backgroundColor
            case .gradient(let gradient):               gradient.background
        }
    }

    var minTextWidth: CGFloat {
        Text.Size.small.lineHeight * sizeCategory.ratio - .xSmall
    }

    var shape: some InsettableShape {
        Capsule()
    }

    var isEmpty: Bool {
        leadingIcon.isEmpty && label.isEmpty && trailingIcon.isEmpty
    }

    var labelColor: Color {
        switch style {
            case .light:                                return .inkDark
            case .lightInverted:                        return .whiteNormal
            case .neutral:                              return .inkDark
            case .status(let status, false):            return (status ?? defaultStatus).darkColor
            case .status(_, true):                      return .whiteNormal
            case .custom(let labelColor, _, _):         return labelColor
            case .gradient:                             return .whiteNormal
        }
    }

    var defaultStatus: Status {
        status ?? .info
    }
}

// MARK: - Inits
public extension Badge {
    
    /// Creates Orbit Badge component.
    ///
    /// - Parameters:
    ///   - style: A visual style of component. A `status` style can be optionally modified using `status()` modifier when `nil` value is provided.
    init(
        _ label: String = "",
        icon: Icon.Symbol? = nil,
        trailingIcon: Icon.Symbol? = nil,
        style: BadgeStyle = .neutral
    ) where LeadingIcon == Icon, TrailingIcon == Icon {
        self.init(label, style: style) {
            Icon(icon)
        } trailingIcon: {
            Icon(trailingIcon)
        }
    }

    /// Creates Orbit Badge component with custom icons.
    ///
    /// - Parameters:
    ///   - style: A visual style of component. A `status` style can be optionally modified using `status()` modifier when `nil` value is provided.
    init(
        _ label: String = "",
        style: BadgeStyle = .neutral,
        @ViewBuilder icon: () -> LeadingIcon,
        @ViewBuilder trailingIcon: () -> TrailingIcon = { EmptyView() }
    ) {
        self.label = label
        self.leadingIcon = icon()
        self.trailingIcon = trailingIcon()
        self.style = style
    }
}

// MARK: - Types
public enum BadgeStyle {

    case light
    case lightInverted
    case neutral
    case status(_ status: Status? = nil, inverted: Bool = false)
    case custom(labelColor: Color, outlineColor: Color, backgroundColor: Color)
    case gradient(Gradient)

    public static var status: Self {
        .status(nil)
    }
}

// MARK: - Previews
struct BadgePreviews: PreviewProvider {

    static var previews: some View {
        PreviewWrapper {
            standalone
            sizing
            styles
            gradients
            mix
        }
        .previewLayout(.sizeThatFits)
    }

    static var standalone: some View {
        VStack(spacing: 0) {
            Badge("label", icon: .grid)
            Badge()    // EmptyView
            Badge("")  // EmptyView
        }
        .padding(.medium)
        .previewDisplayName()
    }

    static var sizing: some View {
        VStack(alignment: .trailing, spacing: .xSmall) {
            Group {
                Badge("Badge")
                Badge("Badge", icon: .grid)
                Badge("Badge", icon: .grid, trailingIcon: .grid)
                Badge(icon: .grid)
                Badge("Multiline\nBadge", icon: .grid)
            }
            .measured()
        }
        .padding(.medium)
        .previewDisplayName()
    }

    static var styles: some View {
        VStack(alignment: .leading, spacing: .xLarge) {
            VStack(alignment: .leading, spacing: .medium) {
                badges(.light)
                badges(.lightInverted)
            }

            badges(.neutral)

            statusBadges(.info)
            statusBadges(.success)
            statusBadges(.warning)
            statusBadges(.critical)

            HStack(alignment: .top, spacing: .medium) {
                Badge("Very very very very very long badge")
                Badge("Very very very very very long badge")
            }
        }
        .padding(.medium)
        .previewDisplayName()
    }

    static var gradients: some View {
        VStack(alignment: .leading, spacing: .xLarge) {
            gradientBadge(.bundleBasic)
            gradientBadge(.bundleMedium)
            gradientBadge(.bundleTop)
        }
        .padding(.medium)
        .previewDisplayName()
    }

    static var mix: some View {
        VStack(alignment: .leading, spacing: .xLarge) {
            HStack(spacing: .small) {
                Badge(
                    "Custom",
                    icon: .airplane,
                    style: .custom(
                        labelColor: .blueDark,
                        outlineColor: .blueDark,
                        backgroundColor: .whiteHover
                    )
                )
                .iconColor(.pink)

                Badge("Flag") {
                    CountryFlag("us")
                }

                Badge("Flag", style: .status(.critical, inverted: true)) {
                    CountryFlag("cz")
                }
            }

            HStack(spacing: .small) {
                Badge("SF Symbol", style: .status(.success)) {
                    Icon("info.circle.fill")
                }

                Badge("SF Symbol", style: .status(.warning, inverted: true)) {
                    Image(systemName: "info.circle.fill")
                }
            }
        }
        .padding(.medium)
        .previewDisplayName()
    }

    static func badges(_ style: BadgeStyle) -> some View {
        HStack(spacing: .small) {
            Badge("label", style: style)
            Badge("label", icon: .grid, style: style)
            Badge(icon: .grid, style: style)
            Badge("label", trailingIcon: .grid, style: style)
            Badge("1", style: style)
        }
    }

    static func statusBadges(_ status: Status) -> some View {
        VStack(alignment: .leading, spacing: .medium) {
            badges(.status(status))
            badges(.status(status, inverted: true))
        }
        .previewDisplayName("\(String(describing: status).titleCased)")
    }

    static func gradientBadge(_ gradient: Gradient) -> some View {
        badges(.gradient(gradient))
            .previewDisplayName("\(String(describing: gradient).titleCased)")
    }
}
