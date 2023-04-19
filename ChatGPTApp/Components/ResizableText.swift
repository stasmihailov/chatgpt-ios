//
//  ResizableText.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ResizableText: View {
    static let maxHeight: CGFloat = 300
    
    @Binding var string: String
    @State var textEditorHeight : CGFloat = 20
    
    var body: some View {
        let height = min(ResizableText.maxHeight,
                         max(20, textEditorHeight) + 8)
        
        ZStack(alignment: .leading) {
            Text(string)
                .font(.system(.body))
                .foregroundColor(.clear)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: $string)
                .font(.system(.body))
                .frame(height: height)
        }.onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct ResizableTextWrapper: View {
    @State var text = ""
    
    var body: some View {
        ResizableText(string: $text)
    }
}

struct ResizableTextWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.bg
            VStack(alignment: .leading) {
                Text("ResizableTextWrapper")
                ResizableTextWrapper()
            }
            .padding(80)
        }
    }
}
