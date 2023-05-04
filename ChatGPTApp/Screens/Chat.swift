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
    var bottomPadding: CGFloat
    
    var body: some View {
        let messages = thread
            .messageList
            .sorted(by: { $0.time! < $1.time! })
            .reversed()
        
        List {
            Spacer()
                .frame(height: bottomPadding)
            
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
                           ? AppColors.systemBg
                           : AppColors.bg)
        .listRowSeparator(.hidden)
    }
}

struct Chat: View {
    @EnvironmentObject var keychain: KeychainManagerWrapper
    @EnvironmentObject var api: OpenAIApiWrapper
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var persistence = Persistence.shared

    @State var message = ""
    @State var showAlert = false
    @State var alertText = ""
    @State var chatSettingsIsActive = false
    @StateObject var lastResponse: LWMsg = LWMsg(source: .ASSISTANT)

    @ObservedObject var thread: EChat

    var body: some View {
        let chatInput = ChatInput(message: $message) {
            onSend()
        }
        let messageInput = HStack(alignment: .bottom, spacing: 5) {
            if !thread.messageList.isEmpty {
                chatParamsButton
            }
            chatInput
        }
        .padding(10)
        .tinted()
    
        ZStack {
            if thread.messageList.isEmpty {
                VStack {
                    ChatModelPicker(model: thread.modelBinding)
                        .padding(.bottom, 64)
                    Text("Enter a new message to start the chat. Select a model above (you can change it later)")
                        .foregroundColor(Color(UIColor.systemGray))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding(20)
                
            } else {
                ExistingChatBody(
                    thread: thread,
                    lastResponse: lastResponse,
                    bottomPadding: chatInput.minHeight - 2
                )
                .frame(maxHeight: .infinity)
            }

            VStack {
                Spacer()
                messageInput
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: goBackButton)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
                  message: Text(alertText),
                  dismissButton: .default(Text("OK")) {
                onHideAlert()
            })
        }
    }
    
    var goBackButton: some View {
        Button(action: {
            if thread.messageList.isEmpty {
                discardChat()
            }
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Chats")
            }
        }
    }
    
    var chatParamsButton: some View {
        AppButtons.chatSettings {
            self.chatSettingsIsActive = true
        }
        .background(NavigationLink(
            destination: ChatSettings(chat: thread),
            isActive: $chatSettingsIsActive) {
                EmptyView()
            }
        )
    }
    
    func onSend() {
        if (!lastResponse.text.isEmpty) {
            flushLastMessage()
        }
        
        sendMessage()
    }
    
    func onHideAlert() {
        showAlert = false
        alertText = ""
    }

    private func discardChat() {
        persistence.context.delete(thread)
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
                    self.flushLastMessage()
                    break
                case .failure(let err):
                    self.alertText = err.error
                    self.showAlert = true
                    break
                }
            }, receiveValue: { value in
                self.lastResponse.text.append(value)
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
        let thread = Persistence.shared.fetchChats()[0]

        Chat(thread: thread)
            .environmentObject(keychain)
            .environmentObject(api)
    }
}
