//
//  MultilineText.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct MultilineText: View {
    static let maxHeight: CGFloat = 300
    
    @State var textEditorHeight : CGFloat = 20
    @Binding var input: String
    
    init(_ input: Binding<String>) {
        self._input = input
    }
    
    var body: some View {
        let overlay = Text(input)
            .font(.system(.body))
            .foregroundColor(.clear)
            .background(GeometryReader {
                Color.clear.preference(key: ViewHeightKey.self,
                                       value: $0.frame(in: .local).size.height)
            })

        let editorHeight = min(MultilineText.maxHeight,
                         max(20, textEditorHeight) + 8)
        let editor = TextEditor(text: $input)
            .font(.system(.body))
            .frame(height: editorHeight)
        
        ZStack(alignment: .leading) {
            overlay
            editor
        }.onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
    
    func placeholder(_ placeholder: String, text: Binding<String>) -> some View {
        self.modifier(PlaceholderText(placeholder: placeholder, text: text))
    }
    
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
        }
    }
    
    struct PlaceholderText: ViewModifier {
        let placeholder: String
        @Binding var text: String
        
        func body(content: Content) -> some View {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(.placeholderText))
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                }
                content
            }
        }
    }
}

extension Text {
    func subheadline() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.gray)
    }
}

struct MultilineText_Previews: PreviewProvider {
    struct MultilineTextWrapper: View {
        @State var text = ""
        
        var body: some View {
            MultilineText($text)
        }
    }

    static var previews: some View {
        ZStack {
            AppColors.bg
            VStack(alignment: .leading) {
                Text("MultilineTextWrapper")
                MultilineTextWrapper()
            }
            .padding(80)
        }
    }
}
