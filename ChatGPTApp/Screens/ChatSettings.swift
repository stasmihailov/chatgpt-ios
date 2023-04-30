//
//  ChatSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ChatSettings: View {
    @Binding var chatName: String

    @State private var chatNameState: String
    
    init(chatName: Binding<String>) {
        self._chatName = chatName
        self.chatNameState = chatName.wrappedValue
    }
    
    var body: some View {
        let settings = VStack {
            Image("chatsettings-avatar")
            AppButtons.action(label: "Set new chat icon") {
            }
            ClearableText($chatNameState, placeholder: "Enter chat name")
            Spacer()
        }
        
        let doneButton = Button("Done") {
            chatName = chatNameState
            Persistence.shared.saveContext()
        }
    
        settings
        .padding()
        .background(AppColors.bg)
        .frame(width: .infinity, height: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                doneButton
            }
        }
    }
}
//
//struct ChatSettings_Previews: PreviewProvider {
//    struct ChatSettingsWrapper: View {
//        var body: some View {
//            ChatSettings(chat: ...)
//        }
//    }
//
//    static var previews: some View {
//        ChatSettingsWrapper()
//    }
//}
