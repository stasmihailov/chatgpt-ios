//
//  ContentView.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/04/2023.
//

import SwiftUI

var colorAccent = Color.accentColor;

struct ChatThread {
    var id: String;
    var name: String;
    var lastMessage: String;
    var lastTime: String;
    var pinned: Bool;
}

func time(fromString: String) -> String {
    return fromString
}

var chatEntries: [ChatThread] = [
    ChatThread(
        id: "75f0d964-9e6c-4816-ba5a-7f1dfaf142dd",
        name: "📱 iOS App Development",
        lastMessage: "Sure! In SwiftUI, you can use the TextEditor view",
        lastTime: time(fromString: "17:21"),
        pinned: true
    ),
    ChatThread(
        id: "160abdb5-81a9-4190-8053-ef8aedba2e80",
        name: "🧘🏻‍♀️ Therapy - GPT4",
        lastMessage: "Psychotherapists use various approaches and techniques to help clients address their",
        lastTime: time(fromString: "15:06"),
        pinned: true
    )
];

struct ChatList: View {
    var body: some View {
        var chat = List(chatEntries, id: \.id) { entry in
            NavigationLink {
                Text(entry.lastMessage)
            } label: {
                HStack {
                    Text(entry.name)
                    Spacer()
                    Text(entry.lastTime)
                }
            }
        }
        
        NavigationView {
            chat
            .navigationBarTitle("Chats", displayMode: .inline)
            .navigationBarItems(
                leading: Text("Edit")
                    .foregroundColor(colorAccent),
                trailing: Image(systemName: "square.and.pencil")
                    .foregroundColor(colorAccent))
        }
    }
}

struct AppSettings: View {
    @State var apiKey: String;
    
    var body: some View {
        var settings = VStack {
            ClearableText(
                placeholder: "Enter new API key",
                text: apiKey
            )

            Text("Your key is securely stored in the Apple Keychain and leaves your device only during OpenAI API calls")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .font(Font.footnote)
            
            Spacer()
        }
            .padding()
            .background(Color(.systemGray6))
            .frame(width: .infinity, height: .infinity)
            
        
        NavigationView {
            settings
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Text("Done")
                    .foregroundColor(colorAccent))
        }
    }
}

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
    }
}
