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
    @EnvironmentObject var persistence: Persistence

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
    
    var pinnedChats: [EChat] { get { chats.filter { $0.pinned } } }
    var unpinnedChats: [EChat] { get { chats.filter { !$0.pinned } } }

    var body: some View {
        NavigationStack {
            ExistingChatList()
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !network.isConnected {
                            OfflineModeLabel()
                        }

                        AppButtons.newChat()
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
                Section {
                    ForEach(pinnedChats, id: \.self) { chat in
                        ChatListCell(thread: chat)
                    }
                }
                Section {
                    ForEach(unpinnedChats, id: \.self) { chat in
                        ChatListCell(thread: chat)
                    }
                } header: {
                    if !pinnedChats.isEmpty && !unpinnedChats.isEmpty {
                        HStack {
                            Text("Unpinned").subheadline()
                            Spacer()
                            AppButtons.destructive(label: "Delete all") {
                                unpinnedChats.forEach { chat in
                                    persistence.delete(chat: chat)
                                }
                            }
                        }
                    }
                }
            }.listStyle(PlainListStyle())
        }
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
            .environmentObject(Persistence.shared)
    }
}
