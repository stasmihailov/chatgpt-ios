//
//  ChatSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ChatSettings: View {
    @ObservedObject var chat: TChat
    @State var threadName: String
    
    init(chat: TChat) {
        self.chat = chat
        self.threadName = chat.name
    }
    
    var body: some View {
        let settings = VStack {
            Image("chatsettings-avatar")
            ActionButton(label: "Set new chat icon")
            ClearableText(placeholder: "Enter chat name", text: $threadName)
            Spacer()
        }
        
        let backButton = Button("Back") {
        }
        
        let doneButton = Button("Done") {
            chat.name = threadName
        }
        
        NavigationView {
            settings
            .padding()
            .background(AppColors.bg)
            .frame(width: .infinity, height: .infinity)
            .navigationBarItems(
                leading: backButton,
                trailing: doneButton)
        }
            
    }
}

struct ChatSettings_Previews: PreviewProvider {
    struct ChatSettingsWrapper: View {
        var body: some View {
            ChatSettings(chat: threads.chats[0])
        }
    }
    
    static var previews: some View {
        ChatSettingsWrapper()
    }
}
