//
//  Buttons.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

final class AppButtons {
    static func search() -> some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(AppColors.accent)
    }
    
    static func write(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "square.and.pencil")
                .foregroundColor(AppColors.accent)
        }
    }
    
    static func action(label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .foregroundColor(AppColors.accent)
        }
    }
}
