import UIKit
import SwiftUI

/// A view representing `TextLink` layer.
public final class TextLinkView: UITextView, UITextViewDelegate {

    let action: TextLink.Action

    override public var canBecomeFirstResponder: Bool {
        // disable text selection while allowing link interaction
        false
    }

    public init(layoutManager: NSLayoutManager = .init(), action: @escaping TextLink.Action) {
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.allowsNonContiguousLayout = true
        layoutManager.limitsLayoutForSuspiciousContents = false

        self.action = action

        super.init(frame: .zero, textContainer: textContainer)

        delegate = self

        clipsToBounds = false
        backgroundColor = .clear
        isEditable = false
        isSelectable = true
        textDragInteraction?.isEnabled = false
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.heightTracksTextView = false
        textContainer.widthTracksTextView = false
        textContainer.lineFragmentPadding = 0
        isScrollEnabled = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction _: UITextItemInteraction
    ) -> Bool {
        let text = (textView.text as NSString).substring(with: characterRange)
        action(url, text)
        return false
    }

    func update(
        content: NSAttributedString,
        lineLimit: Int,
        color: UIColor?
    ) {
        tintColor = color
        textContainer.maximumNumberOfLines = lineLimit
        self.attributedText = content
    }

    private func removeInsets() {
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        removeInsets()
    }

    override public var intrinsicContentSize: CGSize {
        // Required to fit the SwiftUI content
        .zero
    }
}
