import SwiftUI
import Orbit

struct StorybookBadge {

    static var basic: some View {
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
        .previewDisplayName()
    }

    static var gradient: some View {
        VStack(alignment: .leading, spacing: .xLarge) {
            gradientBadge(.bundleBasic)
            gradientBadge(.bundleMedium)
            gradientBadge(.bundleTop)
        }
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
                        backgroundColor: .whiteNormal
                    )
                )
                .iconColor(.pink)

                Badge("Flag") {
                    CountryFlag("us")
                }
                Badge("Flag", style: .status(.critical, inverted: true)) {
                    CountryFlag("us")
                }
            }

            HStack(spacing: .small) {
                Badge("SF Symbol") {
                    Icon("info.circle.fill")
                }
                Badge("SF Symbol", style: .status(.warning, inverted: true)) {
                    Icon("info.circle.fill")
                }
            }
        }
        .previewDisplayName()
    }

    static func badges(_ style: BadgeStyle) -> some View {
        HStack(spacing: .small) {
            Badge("label", style: style)
            Badge("label", icon: .grid, style: style)
            Badge(icon: .grid, style: style)
            Badge("1", style: style)
        }
    }

    static func statusBadges(_ status: Status) -> some View {
        VStack(alignment: .leading, spacing: .medium) {
            badges(.status(status))
            badges(.status(status, inverted: true))
        }
    }

    static func gradientBadge(_ gradient: Orbit.Gradient) -> some View {
        badges(.gradient(gradient))
    }
}

struct StorybookBadgePreviews: PreviewProvider {

    static var previews: some View {
        OrbitPreviewWrapper {
            StorybookBadge.basic
            StorybookBadge.gradient
            StorybookBadge.mix
        }
    }
}
