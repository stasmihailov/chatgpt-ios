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
                           ? AppColors.systemBg
                           : AppColors.bg)
        .listRowSeparator(.hidden)
    }
}

struct ChatModelPicker: View {
    @Binding var model: String?
    var label = true
    var padding: CGFloat = 4.0
    
    var body: some View {
        VStack(alignment: .leading) {
            if label{
                Text("Model")
                    .font(.caption)
                    .padding(.leading, 15)
            }

            Picker("Model", selection: $model) {
                Text("gpt-3.5-turbo")
                Text("gpt-4")
            }
            .pickerStyle(.menu)
            .padding(padding)
            .background(AppColors.bg)
            .cornerRadius(10)
        }
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
        let messageInput = HStack(alignment: .bottom, spacing: 5) {
            chatParamsButton
            ChatInput(message: $message) {
                onSend()
            }
        }
        .padding(10)
        .background(AppColors.bg)

        VStack(spacing: 0) {
            if thread.messageList.isEmpty {
                VStack {
                    ChatModelPicker(model: $thread.model)
                        .padding(.bottom, 64)
                    Text("Enter a new message to start the chat. Select a model above (you can change it later)")
                        .foregroundColor(Color(UIColor.systemGray))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                Spacer()
            } else {
                ExistingChatBody(thread: thread, lastResponse: lastResponse)
                    .frame(maxHeight: .infinity)
            }

            messageInput
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            if thread.messageList.isEmpty {
                discardChat()
            }
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Chats")
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
                  message: Text(alertText),
                  dismissButton: .default(Text("OK")) {
                onHideAlert()
            })
        }
    }
    
    var chatParamsButton: some View {
        AppButtons.chatSettings {
            self.chatSettingsIsActive = true
        }
        .padding(.leading, 8)
        .padding(.trailing, 12)
        .padding(.bottom, 12)
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
        let thread = Persistence.shared.newChat()

        Chat(thread: thread)
            .environmentObject(keychain)
            .environmentObject(api)
    }
}
