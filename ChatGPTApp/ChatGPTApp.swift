//
//  ChatGPTAppApp.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/04/2023.
//

import SwiftUI
import FirebaseCore

@main
struct ChatGPTApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AppBody()
        }
    }
}
