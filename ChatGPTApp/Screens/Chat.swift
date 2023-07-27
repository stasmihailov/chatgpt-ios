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

struct Chat: View {
    @EnvironmentObject var keychain: KeychainManagerWrapper
    @EnvironmentObject var api: OpenAIApiWrapper
    @EnvironmentObject var persistence: Persistence
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var message = ""
    @State var showAlert = false
    @State var alertText = ""
    @State var chatSettingsIsActive = false

    var thread: EChat
    var threadB: BChat { get { thread.bind(to: persistence) } }

    var body: some View {
        let chatInput = ChatInput(message: $message) {
            sendMessage()
        }
        let messageInput = HStack(alignment: .bottom, spacing: 5) {
            if !thread.messages.isEmpty {
                chatParamsButton
            }
            chatInput
        }
        .padding(10)
        .tinted()
    
        ZStack {
            if thread.messages.isEmpty {
                VStack {
                    ChatModelPicker(model: threadB.model)
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
                    bottomPadding: chatInput.minHeight - 2
                )
                .frame(maxWidth: .infinity)
            }

            VStack {
                Spacer()
                messageInput
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
                  message: Text(alertText),
                  dismissButton: .default(Text("OK")) {
                onHideAlert()
            })
        }.onDisappear {
            if thread.messages.isEmpty {
                discardChat()
            }
        }
    }
    
    var chatParamsButton: some View {
        AppButtons.chatSettings {
            self.chatSettingsIsActive = true
        }
        .background(NavigationLink(
            destination: ChatSettings(name: threadB.name, model: threadB.model),
            isActive: $chatSettingsIsActive) {
                EmptyView()
            }
        )
    }

    func onHideAlert() {
        showAlert = false
        alertText = ""
    }

    private func discardChat() {
        persistence.delete(chat: thread)
    }

    private func sendMessage() {
        guard let token = keychain.getApiToken() else {
            print("token is empty")
            return
        }

        let msg = message
        threadB.messages.wrappedValue = thread.messages + [EMsg(source: .USER, text: msg)]
        message = ""
        
        var lastResponse = EMsg(source: .ASSISTANT, text: "")
        threadB.messages.wrappedValue = thread.messages + [lastResponse]
        persistence.update(chat: thread)

        api.chatCompletion(for: thread, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    self.alertText = err.error
                    self.showAlert = true
                    break
                }
                persistence.update(chat: thread)
            }, receiveValue: { value in
                lastResponse.text.append(value)
            }).store(in: &api.cancellables)
    }
}

struct ExistingChatBody: View {
    var thread: EChat
    var bottomPadding: CGFloat
    
    var body: some View {
        let messages = thread.sortedMessages.reversed()
        
        List {
            Spacer()
                .frame(height: bottomPadding)

            ForEach(messages, id: \.self) { message in
                Msg(.from(message))
            }
        }
        .listStyle(PlainListStyle())
        .flip()
    }
    
    func Msg(_ msg: LWMsg) -> some View {
        ChatMessage(message: msg)
        .listRowBackground(msg.source == .USER
                           ? AppColors.systemBg
                           : AppColors.bg)
        .listRowSeparator(.hidden)
    }
}

struct Chat_Previews: PreviewProvider {
    static var keychain: KeychainManagerWrapper {
        let keychain = KeychainManagerWrapper(KeychainManagerImpl())
        
        return keychain
    }
    
    private struct Preview: View {
        @State var persistence = Persistence()
        
        init() {
            persistence.fetchChats()
        }
        
        var body: some View {
            if persistence.chats.isEmpty {
                Text("Waiting for chats...")
            } else {
                let api = OpenAIApiWrapper(OpenAIApiImpl(keychain: keychain))
                var thread = persistence.chats[0]
                
                Chat(thread: thread)
                    .environmentObject(keychain)
                    .environmentObject(api)
                    .environmentObject(persistence)
                    .environmentObject(NetworkStatus())
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
