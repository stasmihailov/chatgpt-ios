//
//  ChatSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ChatSettings: View {
    @ObservedObject var chat: EChat

    @State private var chatNameState: String
    @State private var modelState: String

    init(chat: EChat) {
        self.chat = chat
        self.chatNameState = chat.name ?? ""
        self.modelState = chat.modelBinding.wrappedValue
    }
    
    var body: some View {
        let avatarSettings = HStack {
            Image("chatlist-chatgpt-logo")
            Spacer(minLength: 30)
            AppButtons.action(label: "Set custom chat emoji") {
            }
        }
        
        let nameSettings = HStack {
            Text("Name")
            Spacer(minLength: 30)
            ClearableText($chatNameState, placeholder: "Enter chat name")
        }
        
        let modelSettings = HStack {
            Text("Model")
            Spacer(minLength: 30)
            ChatModelPicker(model: $modelState, label: false, padding: 0)
                .padding(.trailing, -13)
        }
        
        let doneButton = Button("Done") {
            chat.name = chatNameState
            chat.model = modelState

            Persistence.shared.saveContext()
        }
    
        VStack {
            Group{
                avatarSettings
                nameSettings
                modelSettings
            }
            Spacer()
        }
        .padding()
        .background(AppColors.bg)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                doneButton
            }
        }.dismissKeyboardOnTap()
    }
}

struct ChatSettings_Previews: PreviewProvider {
    struct ChatSettingsWrapper: View {
        @StateObject var chat: EChat = Persistence.shared.fetchChats()[0]

        var body: some View {
            ChatSettings(chat: chat)
        }
    }

    static var previews: some View {
        ChatSettingsWrapper()
    }
}
