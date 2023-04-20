//
//  ContentView.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/04/2023.
//

import SwiftUI

struct AppBody: View {
    var body: some View {
        TabView {
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

struct ContentView: View {
    var body: some View {
        AppBody()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(threads)
    }
}
