//
//  TextFieldClearButton.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/04/2023.
//


import SwiftUI

extension View {
    func showClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text))
    }
}

extension View {
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

struct ClearableText: View {
    var placeholder: String
    @Binding var text: String
    var secure: Bool
    
    init(placeholder: String, text: Binding<String>, secure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.secure = secure
    }

    var body: some View {
        if secure {
            SecureField(placeholder, text: $text)
                .frame(height: 22)
                .showClearButton($text)
                .padding(16)
                .background(Color.white)
                .cornerRadius(8)
        } else {
            TextField(placeholder, text: $text)
                .frame(height: 22)
                .showClearButton($text)
                .padding(16)
                .background(Color.white)
                .cornerRadius(8)
        }
    }
}

struct ClearableText_Previews: PreviewProvider {
    struct ClearableTextPreviewWrapper: View {
        @State var text: String = ""
        
        var body: some View {
            ClearableText(
                placeholder: "ClearableText",
                text: $text)
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
