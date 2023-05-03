//
//  ChatInput.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 30/04/2023.
//

import SwiftUI

struct ChatInput: View {
    @Binding var message: String
    let onSend: () -> Void
    
    var canSend: Bool {
        !message.isEmpty
    }
    
    var sendAction: () -> Void {
        canSend ? onSend : {}
    }
    
    var maxHeight: CGFloat {
        get {
            return 40
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            chatText
            sendButton
        }
    }
    
    var chatText: some View {
        ZStack {
            MultilineText($message)
                .placeholder("Type a message", text: $message)
                .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .background(AppColors.systemBg)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .font(.body)
            Text(message).opacity(0).padding(.all, 8)
        }
        .frame(maxHeight: maxHeight)
    }
    
    var sendButton: some View {
        let button = Image(systemName: "paperplane.fill")
            .padding(8)
        return Button(action: sendAction) {
            if !canSend {
                button
                    .foregroundColor(Color(.systemGray))
                    .clipShape(Circle())
            } else {
                button
                    .foregroundColor(AppColors.systemBg)
                    .background(Color.green)
                    .clipShape(Circle())
            }
        }.disabled(!canSend)
    }
}
