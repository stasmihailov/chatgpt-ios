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
    @ObservedObject var chat: EChat
    
    var body: some View {
        Image(systemName: "slider.horizontal.3")
            .padding(.leading, 8)
            .padding(.trailing, 12)
            .padding(.bottom, 12)
            .foregroundColor(Color(.systemGray))
            .background(
                NavigationLink("xxxx") {
                    ChatSettings(chat: chat)
                }
            )
    }
}

struct ChatSendButton: View {
    var canSend: Bool
    var action: () -> Void
    
    var body: some View {
        let button = Image(systemName: "paperplane.fill")
            .padding(8)
        
        Button(action: {
            if canSend {
                action()
            }
        }) {
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
        }.disabled(!canSend)
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

class DateUtils {
    static let shared = DateUtils()
    let fmt = DateFormatter()

    init() {
        fmt.timeStyle = .short
    }
}

extension Date {
    func timeString() -> String {
        return DateUtils.shared.fmt.string(from: self)
    }
}

struct ChatMessage: View {
    let state: ChatMessageState = .SENT
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
                Spacer()
            }
            HStack {
                Spacer()
                if state == .SENT {
                    Text(message.time.timeString()).subheadline()
                } else {
                    Text("...").subheadline()
                }
            }
        }
        .flip()
    }
}

struct NewChatBody: View {
    @ObservedObject var thread: EChat
    
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
        VStack {
            ChatModelPicker(model: thread.modelBinding)
                .padding(.bottom, 64)
            Text("Enter a new message to start the chat. Select a model above (you can change it later)")
                .foregroundColor(Color(UIColor.systemGray))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        Spacer()
    }
}

struct ExistingChatBody: View {
    @ObservedObject var thread: EChat
    @ObservedObject var lastResponse: LWMsg

    struct Msg: View {
        let thread: String
        @ObservedObject var msg: LWMsg
        
        var body: some View {
            ChatMessage(message: msg)
            .navigationTitle(thread)
            .navigationBarItems(trailing: SearchButton())
            .listRowBackground(msg.source == .USER
                               ? Color.white
                               : AppColors.bg)
            .listRowSeparator(.hidden)
        }
    }
    
    var body: some View {
        let messages = thread
            .messages!.compactMap { $0 as? EChatMsg }
            .sorted(by: { $0.time! < $1.time! })
            .reversed()
        
        List {
            if (!lastResponse.text.isEmpty) {
                Msg(thread: thread.name!, msg: lastResponse)
            }

            ForEach(messages, id: \.self) { message in
                Msg(thread: thread.name!, msg: .from(message))
            }
        }
        .listStyle(PlainListStyle())
        .flip()
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
            ChatParametersButton(chat: thread)
            ChatInput(message: $message)
            ChatSendButton(canSend: !message.isEmpty) {
                if (!lastResponse.text.isEmpty) {
                    flushLastMessage()
                }
                
                sendMessage()
            }
        }
        .padding(10)
        .background(AppColors.bg)
        
        NavigationView {
            VStack(spacing: 0) {
                if thread.messageList.isEmpty {
                    NewChatBody(thread: thread)
                } else {
                    ExistingChatBody(thread: thread, lastResponse: lastResponse)
                        .frame(maxHeight: .infinity)
                }
                
                messageInput
            }
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
        let thread = Persistence.shared.newChat()

        Chat(thread: thread)
            .environmentObject(keychain)
            .environmentObject(api)
    }
}
