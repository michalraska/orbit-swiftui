import SwiftUI

/// Orbit label above form fields.
public struct FormFieldLabel: View {

    let label: String
    let accentColor: UIColor?
    let linkColor: TextLink.Color
    let linkAction: TextLink.Action

    public var body: some View {
        Text(label, size: .normal, weight: .medium, accentColor: accentColor, linkColor: linkColor, linkAction: linkAction)
            .padding(.bottom, 1)
            .accessibility(.fieldLabel)
    }

    /// Create Orbit form field label.
    public init(
        _ label: String,
        accentColor: UIColor? = nil,
        linkColor: TextLink.Color = .primary,
        linkAction: @escaping TextLink.Action = { _, _ in }
    ) {
        self.label = label
        self.accentColor = accentColor
        self.linkColor = linkColor
        self.linkAction = linkAction
    }
}

// MARK: - Previews
struct FormFieldLabelPreviews: PreviewProvider {
    
    static var previews: some View {
        PreviewWrapper {
            FormFieldLabel("Form Field Label")
        }
        .previewLayout(.sizeThatFits)
    }
}
