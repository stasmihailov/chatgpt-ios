//
//  TextFieldClearButton.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/04/2023.
//


import SwiftUI

struct ClearableText: View {
    @Binding var text: String
    var placeholder: String
    var secure: Bool
    
    init(_ text: Binding<String>, placeholder: String, secure: Bool = false) {
        self._text = text
        self.placeholder = placeholder
        self.secure = secure
    }

    var body: some View {
        Group {
            if secure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .frame(height: 22)
        .showClearButton($text)
        .padding(16)
        .background(AppColors.systemBg)
        .cornerRadius(8)
    }
}

extension View {
    func showClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text))
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String
    
    func button() -> some View {
        HStack {
            Spacer()
            Button {
                fieldText = ""
            } label: {
                Image(systemName: "multiply.circle.fill")
            }
            .foregroundColor(.secondary)
            .padding(.trailing, 4)
        }
    }

    func body(content: Content) -> some View {
        content.overlay {
            if !fieldText.isEmpty {
                button()
            }
        }
    }
}

extension ClearableText {
    func showUnderline() -> some View {
        self.modifier(TextUnderlineModifier())
    }
}

struct TextUnderlineModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(VStack {
            Divider().offset(x: 0, y: 20)
                .padding()
        })
    }
}

struct ClearableText_Previews: PreviewProvider {
    struct ClearableTextPreviewWrapper: View {
        @State var text: String = ""
        
        var body: some View {
            ClearableText($text, placeholder: "ClearableText")
        }
    }

    static var previews: some View {
        ZStack {
            AppColors.bg
            VStack {
                Text("ClearableText")
                ClearableTextPreviewWrapper()
                Text("ClearableText")
            }
        }
    }
}
