//
//  Chat.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI
import Combine

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

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
                Text(message.text)
                    .textSelection(.enabled)
                Spacer()
            }
            HStack {
                Spacer()
                Text(message.time.userString).subheadline()
            }
        }
        .flip()
    }
}

struct ExistingChatBody: View {
    @ObservedObject var thread: EChat
    @ObservedObject var lastResponse: LWMsg
    
    var body: some View {
        let messages = thread
            .messages!.compactMap { $0 as? EChatMsg }
            .sorted(by: { $0.time! < $1.time! })
            .reversed()
        
        List {
            if (!lastResponse.text.isEmpty) {
                Msg(lastResponse)
            }

            ForEach(messages, id: \.self) { message in
                Msg(.from(message))
            }
        }
        .listStyle(PlainListStyle())
        .flip()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                AppButtons.search()
            }
        }
    }
    
    func Msg(_ msg: LWMsg) -> some View {
        ChatMessage(message: msg)
        .navigationTitle(thread.name!)
        .navigationBarTitleDisplayMode(.inline)
        .listRowBackground(msg.source == .USER
                           ? Color.white
                           : AppColors.bg)
        .listRowSeparator(.hidden)
    }
}

class LWChat: ObservableObject {
    @Published var readyToSend: Bool = false
    var message: String = ""
    var chatModel: String
    
    init(model chatModel: String) {
        self.chatModel = chatModel
    }
    
    func clean() {
        self.message = ""
    }
}

struct NewChatBody: View {
    @ObservedObject var chat: LWChat
    
    struct ChatModelPicker: View {
        @Binding var model: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Model")
                    .font(.caption)
                    .padding(.leading, 15)
                
                Picker("Model", selection: $model) {
                    Text("gpt-3.5-turbo")
                    Text("gpt-4")
                }
                .pickerStyle(.menu)
                .padding(4)
                .background(AppColors.bg)
                .cornerRadius(10)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                ChatModelPicker(model: $chat.chatModel)
                    .padding(.bottom, 64)
                Text("Enter a new message to start the chat. Select a model above (you can change it later)")
                    .foregroundColor(Color(UIColor.systemGray))
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            Spacer()
            
            ChatInput(message: $chat.message) {
                chat.readyToSend = true
            }
            .padding(10)
            .background(AppColors.bg)
        }
    }
}

struct NewChat: View {
    @ObservedObject var chat: LWChat = LWChat(model: "gpt-3.5-turbo")
    @EnvironmentObject var chats: EChats
    
    var body: some View {
        if !chat.readyToSend {
            NewChatBody(chat: chat)
                .onDisappear {
                    chat.clean()
                }
        } else {
            Chat(thread: createChat())
        }
    }
    
    func createChat() -> EChat {
        let chat = chats.newChat()
        chat.model = self.chat.chatModel
        chat.newMessage(source: .USER, text: self.chat.message)
        
        return chat
    }
}

struct Chat: View {
    @State var message = ""
    @State var showAlert = false
    @State var alertText = ""
    @StateObject var lastResponse: LWMsg = LWMsg(source: .ASSISTANT)

    @ObservedObject var thread: EChat
    @EnvironmentObject var keychain: KeychainManagerWrapper
    @EnvironmentObject var api: OpenAIApiWrapper

    var body: some View {
        let messageInput = HStack(alignment: .bottom, spacing: 5) {
            chatParamsButton
            ChatInput(message: $message) {
                if (!lastResponse.text.isEmpty) {
                    flushLastMessage()
                }
                
                sendMessage()
            }
        }
        .padding(10)
        .background(AppColors.bg)

        VStack(spacing: 0) {
            ExistingChatBody(thread: thread, lastResponse: lastResponse)
                .frame(maxHeight: .infinity)
            
            messageInput
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
                  message: Text(alertText),
                  dismissButton: .default(Text("OK")) {
                showAlert = false
                alertText = ""
            })
        }
        // .toolbar(.hidden, for: .tabBar)
    }
    
    
    var chatParamsButton: some View {
        Image(systemName: "slider.horizontal.3")
            .padding(.leading, 8)
            .padding(.trailing, 12)
            .padding(.bottom, 12)
            .foregroundColor(Color(.systemGray))
            .background(
                NavigationLink("xxxx") {
                    ChatSettings(chatName: Binding.constant(thread.name ?? ""))
                }
            )
    }
    
    private func flushLastMessage() {
        thread.addResponse(response: lastResponse)
        lastResponse.reset(source: .ASSISTANT)
        api.cancelCurrent()
    }
    
    private func sendMessage() {
        guard let token = keychain.getApiToken() else {
            print("token is empty")
            return
        }

        let msg = message
        thread.newMessage(source: .USER, text: msg)
        message = ""
        
        lastResponse.reset(source: .ASSISTANT)
        api.chatCompletion(for: thread, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    flushLastMessage()
                    break
                case .failure(let err):
                    alertText = err.error
                    showAlert = true
                    break
                }
            }, receiveValue: { value in
                print("next: " + value)
                lastResponse.text.append(value)
            }).store(in: &api.cancellables)
    }
}

struct Chat_Previews: PreviewProvider {
    static var keychain: KeychainManagerWrapper {
        let keychain = KeychainManagerWrapper(KeychainManagerImpl())
        
        return keychain
    }
    
    static var previews: some View {
        let api = OpenAIApiWrapper(OpenAIApiImpl(keychain: keychain))
        let thread = EChats(chats: []).newChat()

        Chat(thread: thread)
            .environmentObject(keychain)
            .environmentObject(api)
    }
}
