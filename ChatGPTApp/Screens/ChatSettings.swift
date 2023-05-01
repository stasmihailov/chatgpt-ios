//
//  ChatSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ChatSettings: View {
    @Binding var chat: String?
    @State private var chatNameState: String

    init(chat: Binding<String?>) {
        self._chat = chat
        self.chatNameState = chat.wrappedValue ?? ""
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
            chat = chatNameState
            Persistence.shared.saveContext()
        }
    
        settings
        .padding()
        .background(AppColors.bg)
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
