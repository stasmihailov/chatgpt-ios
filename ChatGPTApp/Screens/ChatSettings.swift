//
//  ChatSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ChatSettings: View {
    @State var threadName: String
    
    var body: some View {
        let settings = VStack {
            Image("chatsettings-avatar")
            ActionButton(label: "Set new chat icon")
            ClearableText(placeholder: "Enter chat name", text: $threadName)
            Spacer()
        }
        
        NavigationView {
            settings
            .padding()
            .background(AppColors.bg)
            .frame(width: .infinity, height: .infinity)
            .navigationBarItems(
                leading: Text("Back").foregroundColor(AppColors.accent),
                trailing: Text("Done").foregroundColor(AppColors.accent))
        }
            
    }
}

struct ChatSettings_Previews: PreviewProvider {
    struct ChatSettingsWrapper: View {
        var body: some View {
            ChatSettings(threadName: "Some thread name")
        }
    }
    
    static var previews: some View {
        ChatSettingsWrapper()
    }
}
