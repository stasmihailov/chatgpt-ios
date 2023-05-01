//
//  ContentView.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/04/2023.
//

import SwiftUI

struct AppContainer: View {
    @State var apiKeyEditor: String = ""
    @EnvironmentObject var keychain: KeychainManagerWrapper
    
    var body: some View {
        if keychain.tokenExists {
            mainWindow
        } else {
            let token = keychain.findApiToken()
            switch token {
            case .error(let error):
                Text(error)
            case .notFound:
                Landing(apiKey: $apiKeyEditor, onGetStarted: onTokenSaved)
            case .ok:
                mainWindow
            }
        }
    }
    
    func onTokenSaved() {
        let result = keychain.saveApiToken(apiKeyEditor)
        switch result {
        case .ok:
            break
        case .error(let err):
            print(err)
        }
    }

    var mainWindow: some View {
        return TabView {
            ChatList()
            .tabItem {
                Image(systemName: "message")
                Text("Chats")
            }
            AppSettings(apiKey: "")
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
}

struct AppBody: View {
    var keychain: KeychainManagerWrapper
    var api: OpenAIApiWrapper
    
    init() {
        keychain = KeychainManagerWrapper(KeychainManagerImpl())
        api = OpenAIApiWrapper(OpenAIApiImpl(keychain: keychain))
    }
    
    var body: some View {
        AppContainer()
            .environmentObject(keychain)
            .environmentObject(api)
            .environment(\.managedObjectContext, Persistence.shared.container.viewContext)
    }
}

struct AppBody_Previews: PreviewProvider {
    static var previews: some View {
        AppBody()
    }
}
