//
//  Buttons.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ActionButton: View {
    let label: String
    
    init(label: String = "Edit") {
        self.label = label
    }
    
    var body: some View {
        Text(label)
            .foregroundColor(AppColors.accent)
    }
}

struct WriteButton: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .foregroundColor(AppColors.accent)
    }
}

struct SearchButton: View {
    var body: some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(AppColors.accent)
    }
}
