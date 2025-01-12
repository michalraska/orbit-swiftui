import SwiftUI

/// Groups actionable content to make it easy to scan.
///
/// Can be used standalone or wrapped inside a ``TileGroup``.
///
/// - Note: [Orbit definition](https://orbit.kiwi/components/tile/)
/// - Important: Component expands horizontally unless prevented by `fixedSize` or `idealSize` modifier.
public struct Tile<Content: View, Icon: View>: View {

    @Environment(\.idealSize) private var idealSize
    @Environment(\.isInsideTileGroup) private var isInsideTileGroup
    @Environment(\.isTileSeparatorVisible) private var isTileSeparatorVisible
    @Environment(\.status) private var status
    @Environment(\.isHapticsEnabled) private var isHapticsEnabled

    private let title: String
    private let description: String
    private let disclosure: TileDisclosure
    private let showBorder: Bool
    private let backgroundColor: BackgroundColor?
    private let titleStyle: Heading.Style
    private let descriptionColor: Color
    private let action: () -> Void
    @ViewBuilder private let content: Content
    @ViewBuilder private let icon: Icon

    public var body: some View {
        SwiftUI.Button(
            action: {
                if isHapticsEnabled {
                    HapticsProvider.sendHapticFeedback(.light(0.5))
                }
                
                action()
            },
            label: {
                buttonContent
            }
        )
        .buttonStyle(TileButtonStyle(style: tileBorderStyle, status: status, backgroundColor: backgroundColor))
        .accessibilityElement(children: .ignore)
        .accessibility(label: .init(title))
        .accessibility(hint: .init(description))
        .accessibility(addTraits: .isButton)
    }

    @ViewBuilder var buttonContent: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                header
                content
            }

            if idealSize.horizontal == nil {
                Spacer(minLength: 0)
            }

            TextStrut()
                .textSize(.large)
                .padding(.vertical, TileButtonStyle.verticalTextPadding)

            disclosureIcon
                .padding(.trailing, .medium)
        }
        .overlay(customContentButtonLinkOverlay, alignment: .topTrailing)
        .overlay(separator, alignment: .bottom)
    }
    
    @ViewBuilder var header: some View {
        if isHeaderEmpty == false {
            HStack(alignment: .top, spacing: 0) {
                icon
                    .font(.system(size: Orbit.Icon.Size.fromTextSize(size: titleStyle.size)))
                    .foregroundColor(.inkNormal)
                    .padding(.trailing, .xSmall)
                    .accessibility(.tileIcon)

                VStack(alignment: .leading, spacing: .xxSmall) {
                    Heading(title, style: titleStyle)
                        .accessibility(.tileTitle)

                    Text(description)
                        .textColor(descriptionColor)
                        .accessibility(.tileDescription)
                }

                if idealSize.horizontal == nil {
                    Spacer(minLength: 0)
                }

                inactiveButtonLink
            }
            .padding(.vertical, TileButtonStyle.verticalTextPadding)
            .padding(.horizontal, .medium)
        }
    }

    @ViewBuilder var customContentButtonLinkOverlay: some View {
        if isHeaderEmpty {
            inactiveButtonLink
                .padding(.medium)
        }
    }

    @ViewBuilder var inactiveButtonLink: some View {
        switch disclosure {
            case .none, .icon:
                EmptyView()
            case .buttonLink(let label, let type):
                ButtonLink(label, type: type, action: {})
                    .textColor(nil)
                    .disabled(true)
                    .padding(.vertical, -.xxxSmall)
                    .accessibility(.tileDisclosureButtonLink)
        }
    }

    @ViewBuilder var disclosureIcon: some View {
        switch disclosure {
            case .none, .buttonLink:
                EmptyView()
            case .icon(let icon, _):
                Orbit.Icon(icon)
                    .iconColor(.inkNormal)
                    .padding(.leading, .xSmall)
                    .accessibility(.tileDisclosureIcon)
        }
    }

    @ViewBuilder var separator: some View {
        if isInsideTileGroup, isTileSeparatorVisible {
            Separator()
                .padding(.leading, .medium)
        }
    }

    var separatorPadding: CGFloat {
        icon.isEmpty ? .medium : .xxxLarge
    }
    
    var tileBorderStyle: TileBorderStyle {
        showBorder && isInsideTileGroup == false ? .default : .none
    }
    
    var isHeaderEmpty: Bool {
        title.isEmpty && description.isEmpty && icon.isEmpty
    }
}

// MARK: - Inits
public extension Tile {
    
    /// Creates Orbit Tile component.
    init(
        _ title: String = "",
        description: String = "",
        icon: Icon.Symbol? = nil,
        disclosure: TileDisclosure = .icon(.chevronForward),
        showBorder: Bool = true,
        backgroundColor: BackgroundColor? = nil,
        titleStyle: Heading.Style = .title4,
        descriptionColor: Color = .inkNormal,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) where Icon == Orbit.Icon {
        self.init(
            title,
            description: description,
            disclosure: disclosure,
            showBorder: showBorder,
            backgroundColor: backgroundColor,
            titleStyle: titleStyle,
            descriptionColor: descriptionColor
        ) {
            action()
        } content: {
            content()
        } icon: {
            Icon(icon)
        }
    }

    /// Creates Orbit Tile component with custom icon.
    init(
        _ title: String = "",
        description: String = "",
        disclosure: TileDisclosure = .icon(.chevronForward),
        showBorder: Bool = true,
        backgroundColor: BackgroundColor? = nil,
        titleStyle: Heading.Style = .title4,
        descriptionColor: Color = .inkNormal,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content = { EmptyView() },
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.description = description
        self.disclosure = disclosure
        self.showBorder = showBorder
        self.backgroundColor = backgroundColor
        self.titleStyle = titleStyle
        self.descriptionColor = descriptionColor
        self.action = action
        self.content = content()
        self.icon = icon()
    }
}

// MARK: - Modifiers
public extension Tile {

    /// Sets the visibility of the separator associated with this tile.
    ///
    /// Only applies if the tile is contained in a ``TileGroup``.
    ///
    /// - Parameter isVisible: Whether the separator is visible or not.
    func tileSeparator(_ isVisible: Bool) -> some View {
        self
            .environment(\.isTileSeparatorVisible, isVisible)
    }
}

// MARK: - Types

public extension Tile {

    typealias BackgroundColor = (normal: Color, active: Color)
}

/// Button style wrapper for Tile-like components.
///
/// Solves the touch-down, touch-up animations that would otherwise need gesture avoidance logic.
public struct TileButtonStyle: ButtonStyle {

    public static let verticalTextPadding: CGFloat = 14 // = 52 height @ normal size

    private let style: TileBorderStyle
    private let isSelected: Bool
    private let status: Status?
    private let backgroundColor: Tile.BackgroundColor?

    /// Creates button style wrapper for Tile-like components.
    public init(style: TileBorderStyle = .default, isSelected: Bool = false, status: Status? = nil, backgroundColor: Tile.BackgroundColor? = nil) {
        self.style = style
        self.isSelected = isSelected
        self.status = status
        self.backgroundColor = backgroundColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(backgroundColor(isPressed: configuration.isPressed))
            .tileBorder(
                style,
                isSelected: isSelected
            )
            .status(status)
    }

    func backgroundColor(isPressed: Bool) -> Color {
        switch (backgroundColor, isPressed) {
            case (let backgroundColor?, true):          return backgroundColor.active
            case (let backgroundColor?, false):         return backgroundColor.normal
            case (.none, true):                         return .whiteHover
            case (.none, false):                        return .whiteDarker
        }
    }
}

public enum TileDisclosure: Equatable {
    case none
    /// Icon with optional color override.
    case icon(Icon.Symbol, alignment: VerticalAlignment = .center)
    /// ButtonLink indicator.
    case buttonLink(_ label: String, type: ButtonLinkType = .primary)
}

// MARK: - Identifiers
public extension AccessibilityID {

    static let tileTitle                    = Self(rawValue: "orbit.tile.title")
    static let tileIcon                     = Self(rawValue: "orbit.tile.icon")
    static let tileDescription              = Self(rawValue: "orbit.tile.description")
    static let tileDisclosureButtonLink     = Self(rawValue: "orbit.tile.disclosure.buttonlink")
    static let tileDisclosureIcon           = Self(rawValue: "orbit.tile.disclosure.icon")
}

// MARK: - Previews
struct TilePreviews: PreviewProvider {

    static let title = "Title"
    static let description = "Description"
    static let descriptionMultiline = """
        Description with <strong>very</strong> <ref>very</ref> <u>very</u> long multiline \
        description and <u>formatting</u> with <applink1>links</applink1>
        """

    static var previews: some View {
        PreviewWrapper {
            standalone
            idealSize
            sizing
            tiles
            mix
            customContentMix
        }
        .previewLayout(.sizeThatFits)
    }

    static var standalone: some View {
        VStack(spacing: .medium) {
            Tile(title, description: description, icon: .grid, action: {})
            Tile(title, description: description, icon: .grid, action: {}) {
                contentPlaceholder
            }
        }
        .padding(.medium)
        .previewDisplayName()
    }

    static var idealSize: some View {
        Tile(title, description: description, icon: .grid, action: {})
            .idealSize()
            .padding(.medium)
            .previewDisplayName()
    }

    static var sizing: some View {
        VStack(spacing: .medium) {
            Group {
                Tile("Tile", description: description, icon: .grid, action: {})
                Tile("Tile", icon: .grid, action: {})
                Tile(icon: .grid, action: {})
                Tile(description: "Tile", icon: .grid, action: {})
                Tile(description: "Tile", disclosure: .none, action: {})
                Tile("Tile", action: {})
            }
            .measured()
        }
        .padding(.medium)
        .previewDisplayName()
    }

    static var tiles: some View {
        VStack(spacing: .large) {
            Tile(title, action: {})
            Tile(title, icon: .airplane, action: {})
            Tile(title, description: description, action: {})
            Tile(title, description: description, icon: .airplane, action: {})
            Tile {
                // No action
            } content: {
                contentPlaceholder
            }
        }
        .padding(.medium)
        .previewDisplayName()
    }

    @ViewBuilder static var mix: some View {
        VStack(spacing: .large) {
            Tile("Title with very very very very very long multiline text", description: descriptionMultiline, icon: .airplane, action: {}) {
                contentPlaceholder
            }

            Tile(title, description: description, icon: .airplane) {
                // No action
            }
            .iconColor(.blueNormal)
            .status(.info)

            Tile("SF Symbol", description: description) {
                // No action
            } icon: {
                Icon("info.circle.fill")
            }
            .status(.critical)

            Tile("Country Flag", description: description, icon: .grid, disclosure: .buttonLink("Action", type: .primary), action: {})
            Tile(title, description: description, icon: .airplane, disclosure: .buttonLink("Action", type: .critical), action: {})
            Tile(title, description: description, icon: .airplane, disclosure: .icon(.grid), action: {})
        }
        .padding(.medium)
        .previewDisplayName()
    }

    @ViewBuilder static var customContentMix: some View {
        VStack(spacing: .large) {
            Tile(disclosure: .none) {
                // No action
            } content: {
                contentPlaceholder
            }
            Tile(disclosure: .buttonLink("Action", type: .critical)) {
                // No action
            } content: {
                contentPlaceholder
            }
            Tile {
                // No action
            } content: {
                contentPlaceholder
            }
            Tile("Tile with custom content", disclosure: .buttonLink("Action", type: .critical)) {
                // No action
            } content: {
                contentPlaceholder
            }
            Tile(
                "Tile with no border",
                description: descriptionMultiline,
                icon: .grid,
                showBorder: false,
                action: {}
            )
        }
        .padding(.medium)
        .previewDisplayName()
    }
}
