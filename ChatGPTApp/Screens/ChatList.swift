//
//  ChatList.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct ChatList: View {
    @EnvironmentObject var keychain: KeychainManagerWrapper
    @EnvironmentObject var api: OpenAIApiWrapper
    @EnvironmentObject var network: NetworkStatus
    static var persistence = Persistence.shared

    @FetchRequest(
        entity: EChat.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "messages.@count > 0")
    ) var allChats: FetchedResults<EChat>
    
    var chats: [EChat] {
        get {
            return allChats
                .sorted { $0.lastMessageTime > $1.lastMessageTime }
                .sorted(using: SortDescriptor(\EChat.pinned, order: .reverse))
        }
    }

    @State var newChat: EChat? = nil
    @State var newChatIsActive: Bool = false

    var body: some View {
        NavigationView {
            ExistingChatList()
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if newChat != nil {
                            NewChatNavigationLink()
                        }
                        
                        if !network.isConnected {
                            OfflineModeLabel()
                        }

                        AppButtons.write {
                            newChat = ChatList.persistence.newChat()
                            newChatIsActive = true
                        }
                    }
                }
            }
        }
    }
    
    private func ExistingChatList() -> some View {
        VStack {
            if chats.isEmpty {
                Text("Start a new chat by tapping the button above").subheadline()
                .padding(.top, 100)
            }
            
            List {
                ForEach(chats, id: \.self) { chat in
                    ChatListCell(thread: chat)
                }
            }.listStyle(PlainListStyle())
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
        let keychain = KeychainManagerWrapper(KeychainManagerImpl())
        let api = OpenAIApiWrapper(OpenAIApiImpl(keychain: keychain))
    
        ChatList()
            .environmentObject(keychain)
            .environmentObject(api)
            .environmentObject(NetworkStatus())
    }
}
