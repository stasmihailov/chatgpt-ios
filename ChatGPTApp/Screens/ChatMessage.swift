//
//  ChatMessage.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 08/05/2023.
//

import SwiftUI

struct ChatMessage: View {
    @ObservedObject var message: LWMsg

    var body: some View {
        let chatAvatar = Image(message.source == .ASSISTANT
                               ? "chat-avatar-assistant"
                               : "chat-avatar-user")

        VStack {
            HStack(alignment: .top) {
                chatAvatar
                    .padding(.top, 4)
                    .padding(.trailing, 8)
                if message.text.isEmpty {
                    ProgressView()
                } else {
                    SelectableText(message.text)
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text(message.time.userString).subheadline()
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 4)
        .flip()
    }
}
