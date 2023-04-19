//
//  Chat.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

struct ChatInput: View {
    @Binding var message: String
    
    var body: some View {
        ZStack {
            ResizableText(string: $message)
                .placeholder("Type a message", text: $message)
                .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .font(.body)
            Text(message).opacity(0).padding(.all, 8)
        }
    }
}

struct ChatParametersButton: View {
    var body: some View {
        Image(systemName: "slider.horizontal.3")
            .padding(.leading, 8)
            .padding(.trailing, 12)
            .padding(.bottom, 12)
            .foregroundColor(Color(.systemGray))
    }
}

struct ChatSendButton: View {
    var canSend: Bool
    var action: () -> Void
    
    var body: some View {
        let button = Image(systemName: "paperplane.fill")
            .padding(8)
        
        Button(action: action) {
            if !canSend {
                button
                    .foregroundColor(Color(.systemGray))
                    .clipShape(Circle())
            } else {
                button
                    .foregroundColor(.white)
                    .background(Color.green)
                    .clipShape(Circle())
            }
        }
    }
}

// TODO implement
struct ChatScrollUpButton: View {
    var body: some View {
        EmptyView()
    }
}

enum ChatMessageState {
    case SENDING, SENT;
}

struct ChatMessage: View {
    let state: ChatMessageState = .SENT
    let message: ChatMessageData

    var body: some View {
        let chatAvatar = Image(message.source == .ASSISTANT
                               ? "chat-avatar-assistant"
                               : "chat-avatar-user")

        VStack {
            HStack(alignment: .top) {
                chatAvatar
                    .padding(.top, 4)
                    .padding(.trailing, 8)
                Text(message.text)
                Spacer()
            }
            HStack {
                Spacer()
                if state == .SENT {
                    Text(message.time).subheadline()
                } else {
                    Text("...").subheadline()
                }
            }
        }
        .flip()
    }
}

struct NewChatBody: View {
    @Binding var thread: ChatThreadData
    
    struct ChatModelPicker: View {
        @Binding var model: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Model")
                    .font(.caption)
                    .padding(.leading, 15)
                
                Picker("Model", selection: $model) {
                    Text("chatgpt-3.5")
                    Text("chatgpt-4")
                }
                .pickerStyle(.menu)
                .padding(4)
                .background(AppColors.bg)
                .cornerRadius(10)
            }
        }
    }

    var body: some View {
        VStack {
            ChatModelPicker(model: $thread.model)
                .padding(.bottom, 64)
            Text("Enter a new message to start the chat. Select a model above (you can change it later)")
                .foregroundColor(Color(UIColor.systemGray))
                .multilineTextAlignment(.center)
                .navigationTitle(thread.name)
        }
        .padding(20)
        Spacer()
    }
}

struct ExistingChatBody: View {
    let thread: ChatThreadData

    var body: some View {
        List {
            ForEach(thread.messages.reversed(), id: \.id) { message in
                ChatMessage(message: message)
                .navigationTitle(thread.name)
                .navigationBarItems(trailing: SearchButton())
                .listRowBackground(message.source == .USER
                                   ? Color.white
                                   : AppColors.bg)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .flip()
    }
}

struct Chat: View {
    @State var message = ""
    @State var thread: ChatThreadData
    
    var body: some View {
        let messageInput = HStack(alignment: .bottom, spacing: 5) {
            ChatParametersButton()
            ChatInput(message: $message)
            ChatSendButton(canSend: !message.isEmpty) {
            }
        }
        .padding(10)
        .background(AppColors.bg)
        
        VStack(spacing: 0) {
            if thread.messages.isEmpty {
                NewChatBody(thread: $thread)
            } else {
                ExistingChatBody(thread: thread)
                    .frame(maxHeight: .infinity)
            }
                
            messageInput
        }
        // .toolbar(.hidden, for: .tabBar)
    }
}

struct Chat_Previews: PreviewProvider {
    static var previews: some View {
        Chat(thread: threads[0])
    }
}
