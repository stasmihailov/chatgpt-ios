//
//  ChatGPTAppApp.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/04/2023.
//

import SwiftUI

@main
struct ChatGPTApp: App {
    var body: some Scene {
        let chats: EChats = Persistence.shared.fetchChats()
        
        WindowGroup {
            AppBody()
                .environmentObject(chats)
        }
    }
}
