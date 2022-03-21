import Combine
import SwiftUI

/// A  companion component to ``Text`` that only shows TextLinks, detected in html formatted content.
///
/// - Related components:
///   - ``Text``
///
/// - Note: [Orbit definition](https://orbit.kiwi/components/textlink/)
@available(iOS, deprecated: 15.0, message: "Will be replaced with a native markdown-enabled Text component")
public struct TextLink: UIViewRepresentable {

    /// An action handler for a link tapped inside the ``Text`` component.
    public typealias Action = (URL, String) -> Void
    public static let defaultColor: UIColor = .productDark

    let content: NSAttributedString
    let size: CGSize
    let color: UIColor
    let action: Action
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: UIViewRepresentableContext<TextLink>) -> TextLinkView {
        let textLinkView = TextLinkView(layoutManager: NSLayoutManager(), size: size, action: action)
        
        let tapRecognizer = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleLinkTap)
        )
        
        textLinkView.addGestureRecognizer(tapRecognizer)
        return textLinkView
    }

    public func updateUIView(_ uiView: TextLinkView, context: UIViewRepresentableContext<TextLink>) {
        uiView.update(
            content: content,
            size: size,
            lineLimit: context.environment.lineLimit ?? 0,
            color: color
        )
    }
    
    public class Coordinator {
        var parent: TextLink

        init(_ textLink: TextLink) {
            parent = textLink
        }
        
        /// Allows to handle link tap quicker than delayed `textView(shouldInteractWith:)`.
        @objc func handleLinkTap(_ recognizer: UITapGestureRecognizer) {
            guard let textView = recognizer.view as? UITextView else { return }
            
            let tapLocation = recognizer.location(in: recognizer.view)
            let glyphIndex = textView.layoutManager.glyphIndex(for: tapLocation, in: textView.textContainer)
            let characterIndex = textView.layoutManager.characterIndexForGlyph(at: glyphIndex)
        
            guard let attributedText = textView.attributedText else { return }
            
            let fullRange = NSRange(location: 0, length: attributedText.length)

            attributedText.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
                if NSLocationInRange(characterIndex, range), let url = attributes[.link] as? URL {
                    let text = attributedText.attributedSubstring(from: range).string
                    parent.action(url, text)
                    return
                }
            }
        }
    }
}

// MARK: - Previews
struct TextLinkPreviews: PreviewProvider {
 
    static var previews: some View {
        PreviewWrapperWithState(initialState: (0, "")) { state in
            VStack(spacing: .xLarge) {
                Text("Text containing <a href=\"...\">Some TextLink</a> and <a href=\"...\">Another TextLink</a>") { link, text in
                    state.wrappedValue.0 += 1
                    state.wrappedValue.1 = text
                }
                
                ButtonLink("ButtonLink") {
                    state.wrappedValue.0 += 1
                    state.wrappedValue.1 = ""
                }
                
                Button("Button") {
                    state.wrappedValue.0 += 1
                    state.wrappedValue.1 = ""
                }
                
                Text("Tapped \(state.wrappedValue.0)x", color: .inkLight)
                Text("Link text: \(state.wrappedValue.1)", color: .inkLight)
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
