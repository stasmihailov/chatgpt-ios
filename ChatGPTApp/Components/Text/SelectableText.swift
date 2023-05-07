//
//  SelectableText.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 07/05/2023.
//
import SwiftUI
import UIKit
import Down

struct SelectableText: UIViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme
    var text: String
    
    init(_ text: String) {
        self.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let myTextView = UITextView()
        myTextView.delegate = context.coordinator
        myTextView.isEditable = false
        myTextView.isUserInteractionEnabled = true
        myTextView.isSelectable = true
        myTextView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        myTextView.isScrollEnabled = false
        myTextView.textContainer.lineFragmentPadding = 0
        myTextView.textContainerInset = .zero
        myTextView.backgroundColor = .clear
        myTextView.textContainer.maximumNumberOfLines = 0
        myTextView.textContainer.lineBreakMode = .byWordWrapping
        myTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return myTextView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if let markdown = try? Down(markdownString: text).toAttributedString() {
            let msgText = NSMutableAttributedString(attributedString: markdown)
            msgText.attr(.foregroundColor, value: uiView.textColor!)
            msgText.attr(.backgroundColor, value: UIColor.clear)
            msgText.attr(.font, value: uiView.font!)
            
            uiView.attributedText = msgText
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SelectableText

        init(_ parent: SelectableText) {
            self.parent = parent
        }
    }
}

extension NSMutableAttributedString {
    func attr(_ key: NSAttributedString.Key, value: Any) {
        self.addAttribute(key, value: value,
                          range: NSRange(location: 0, length: self.length))
    }
}

struct SelectableText_Previews: PreviewProvider {
    struct SelectableTextContainer: View {
        var text: String = """
            hello **darkness** my old friend
            ```swift
            struct X: View {
                var body: Some View {
                    VStack {
                    }
                }
            }
            ```

            """

        var body: some View {
            SelectableText(text)
        }
    }
    
    static var previews: some View {
        SelectableTextContainer()
    }
}
