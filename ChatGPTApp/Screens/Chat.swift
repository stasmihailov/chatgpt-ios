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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var persistence = Persistence.shared

    @State var message = ""
    @State var showAlert = false
    @State var alertText = ""
    @State var chatSettingsIsActive = false

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
                    bottomPadding: chatInput.minHeight - 2
                )
                .frame(maxHeight: .infinity)
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
        sendMessage()
    }
    
    func onHideAlert() {
        showAlert = false
        alertText = ""
    }

    private func discardChat() {
        persistence.context.delete(thread)
    }

    private func sendMessage() {
        guard let token = keychain.getApiToken() else {
            print("token is empty")
            return
        }

        let msg = message
        thread.newMessage(source: .USER, text: msg)
        message = ""
        
        var lastResponse = thread.newMessage(source: .ASSISTANT, text: "")

        api.chatCompletion(for: thread, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    persistence.saveContext()
                    break
                case .failure(let err):
                    self.alertText = err.error
                    self.showAlert = true
                    break
                }
            }, receiveValue: { value in
                lastResponse.text!.append(value)
                lastResponse.objectWillChange.send()
                thread.objectWillChange.send()
                
                persistence.saveContext()
            }).store(in: &api.cancellables)
    }
}

struct ExistingChatBody: View {
    @ObservedObject var thread: EChat
    var bottomPadding: CGFloat
    
    var body: some View {
        let messages = thread.messageList.reversed()
        
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

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
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
            .environmentObject(NetworkStatus())
    }
}
