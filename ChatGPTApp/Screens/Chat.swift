//
//  Chat.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

enum ChatMessageRole {
    case USER, ASSISTANT;
}

struct ChatMessage {
    var id: String;
    var source: ChatMessageRole;
    var time: String;
    var text: String;
}

struct ChatAvatar: View {
    var message: ChatMessage
    
    var body: some View {
        if message.source == .ASSISTANT {
            Image("chat-avatar-assistant")
        } else {
            Image("chat-avatar-user")
        }
    }
}

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

struct Chat: View {
    var thread: ChatThread
    
    var body: some View {
        var chatBody = List {
            ForEach(thread.messages.reversed(), id: \.id) { message in
                VStack {
                    HStack(alignment: .top) {
                        ChatAvatar(message: message)
                            .padding(.top, 4)
                            .padding(.trailing, 8)
                        Text(message.text)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(message.time).subheadline()
                    }
                }
                .navigationTitle(thread.name)
                .navigationBarItems(trailing: Image(systemName: "magnifyingglass").foregroundColor(AppColors.accent))
                .flip()
//                .background(message.source == .USER
//                            ? Color.white
//                            : AppColors.chatResponseBg)
            }
        }
            .listStyle(PlainListStyle())
            .flip()
        
        chatBody
    }
}

struct Chat_Previews: PreviewProvider {
    static var previews: some View {
        Chat(thread: threads[0])
    }
}
