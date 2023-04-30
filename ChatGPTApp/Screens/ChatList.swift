//
//  ChatList.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct ChatList: View {
    @State var newChat: EChat? = nil
    @State var newChatIsActive: Bool = false

    @EnvironmentObject var chats: EChats
    
    var body: some View {
        let chatsList = chats.chats
            .filter { !$0.messageList.isEmpty }

        NavigationView {
            Group {
                if chatsList.isEmpty {
                    ChatListPlaceholder()
                } else {
                    ExistingChatList()
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !chatsList.isEmpty {
                    deleteAllButton()
                }
                newChatButton()
            }
        }
    }
    
    private func ChatListPlaceholder() -> some View {
        VStack {
            Text("Start a new chat by tapping the button above").subheadline()
            Spacer()
            
            if newChat != nil {
                NewChatNavigationLink()
            }
        }
        .padding(.top, 100)
    }
    
    private func ExistingChatList() -> some View {
        let now = Date()
        let sortedChats = chats.chats
            .sorted { $0.pinned && !$1.pinned }
            .sorted { $0.lastMessageTime ?? now > $1.lastMessageTime ?? now }
        
        return List {
            ForEach(sortedChats, id: \.self) { chat in
                ChatListCell(thread: chat)
            }

            if newChat != nil {
                NewChatNavigationLink()
            }
        }.listStyle(PlainListStyle())
    }
    
    private func deleteAllButton() -> ToolbarItem<(), some View> {
        return ToolbarItem(placement: .navigationBarLeading) {
            AppButtons.action(label: "Delete all") {
                Persistence.shared.deleteAllEntities()
            }
        }
    }
    
    private func newChatButton() -> ToolbarItem<(), some View> {
        return ToolbarItem(placement: .navigationBarTrailing) {
            AppButtons.write {
                newChat = chats.newChat()
                newChatIsActive = true
            }
        }
    }
    
    private func NewChatNavigationLink() -> some View {
        NavigationLink(
            destination: Chat(thread: newChat!),
            isActive: $newChatIsActive
        ) {
            EmptyView()
        }.hidden()
    }
}

struct ChatList_Previews: PreviewProvider {
    static var previews: some View {
        let chats = Persistence.shared.fetchChats()
        let keychain = KeychainManagerWrapper(KeychainManagerImpl())
        let api = OpenAIApiWrapper(OpenAIApiImpl(keychain: keychain))
    
        ChatList()
            .environmentObject(chats)
            .environmentObject(keychain)
            .environmentObject(api)
    }
}
