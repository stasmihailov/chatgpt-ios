//
//  ChatSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

struct ChatSettings: View {
    @EnvironmentObject var persistence: Persistence
    
    @Binding var name: String
    @Binding var model: String

    @State private var chatNameState: String = ""
    @State private var modelState: String = ""

    init(name: Binding<String>, model: Binding<String>) {
        self._name = name
        self._model = model
        
        self.chatNameState = name.wrappedValue
        self.modelState = model.wrappedValue
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
            name = chatNameState
            model = modelState
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

//struct ChatSettings_Previews: PreviewProvider {
//    struct ChatSettingsWrapper: View {
//        @State var chat: EChat = Persistence.shared.fetchChats()[0]
//
//        var body: some View {
//            ChatSettings(chat: chat)
//        }
//    }
//
//    static var previews: some View {
//        ChatSettingsWrapper()
//            .environmentObject(Persistence.shared)
//    }
//}
