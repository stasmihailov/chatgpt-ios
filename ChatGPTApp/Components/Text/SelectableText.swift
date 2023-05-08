//
//  SelectableText.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 07/05/2023.
//
import SwiftUI
import UIKit
import Introspect

struct SelectableText: View {
    @State var textEditorHeight : CGFloat = 0
    var input: String
    
    init(_ input: String) {
        self.input = input
    }
    
    var body: some View {
        let overlay = Text(input)
            .font(.system(.body))
            .foregroundColor(.clear)
            .background(GeometryReader {
                Color.clear.preference(key: ViewHeightKey.self,
                                       value: $0.frame(in: .local).size.height)
            })

        let editorHeight = textEditorHeight + 18
        let editor = TextEditor(text: .constant(input))
            .font(.system(.body))
            .frame(height: editorHeight)
            .fixedSize(horizontal: false, vertical: true)
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .background(.clear)
            .introspectTextView {
                $0.isEditable = false
                $0.textContainer.lineFragmentPadding = 0
                $0.textContainerInset = .zero
            }
        
        ZStack(alignment: .leading) {
            overlay
            editor
        }.onPreferenceChange(ViewHeightKey.self) {
            textEditorHeight = $0
        }
    }
    
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
        }
    }
}
