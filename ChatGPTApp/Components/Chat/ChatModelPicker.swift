//
//  ChatModelPicker.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 03/05/2023.
//

import SwiftUI

struct ChatModelPicker: View {
    private static let defaultSelection = "gpt-3.5-turbo"
    private static let allSelections = [
        defaultSelection,
        "gpt-4",
    ]
    
    @Binding var model: String
    var label = true
    var padding: CGFloat = 4.0
    
    var body: some View {
        VStack(alignment: .leading) {
            if label {
                Text("Model")
                    .font(.caption)
                    .padding(.leading, 15)
            }

            Picker("Model", selection: $model) {
                ForEach(ChatModelPicker.allSelections, id: \.self) { m in
                    Text(m).tag(m)
                }
            }
            .pickerStyle(.menu)
            .padding(padding)
            .background(AppColors.bg)
            .cornerRadius(10)
        }.onAppear {
            setupDefaultSelection()
        }
    }
    
    private func setupDefaultSelection() {
        if model.isEmpty {
            self.model = ChatModelPicker.defaultSelection
        }
    }
}

