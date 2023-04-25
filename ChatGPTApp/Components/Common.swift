//
//  Common.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

extension View {
    func subheadline() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    func placeholder(_ placeholder: String, text: Binding<String>) -> some View {
        self.modifier(PlaceholderText(placeholder: placeholder, text: text))
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

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

struct AppColors {
    static let accent = Color.accentColor
    static let accentDestructive = Color.red
    static let chatResponseBg = Color(hex: "F7F7F7")
    static let bg = Color(UIColor.secondarySystemBackground)
}
