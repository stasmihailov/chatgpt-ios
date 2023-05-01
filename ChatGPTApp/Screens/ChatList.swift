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
            Group {
                if chats.isEmpty {
                    ChatListPlaceholder()
                } else {
                    ExistingChatList()
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                if !chats.isEmpty {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        AppButtons.action(label: "Delete all") {
//                            Persistence.shared.deleteAllEntities()
//                        }
//                    }
//                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    AppButtons.write {
                        newChat = ChatList.persistence.newChat()
                        newChatIsActive = true
                    }
                }
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
        List {
            ForEach(chats, id: \.self) { chat in
                ChatListCell(thread: chat)
                    .listRowBackground(chat.pinned
                                       ? AppColors.chatResponseBg
                                       : Color.white)
            }

            if newChat != nil {
                NewChatNavigationLink()
            }
        }.listStyle(PlainListStyle())
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
    }
}
