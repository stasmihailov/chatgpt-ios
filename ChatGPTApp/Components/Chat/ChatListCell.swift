//
//  ChatListCell.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 30/04/2023.
//

import SwiftUI

struct ChatListCell: View {
    @EnvironmentObject var persistence: Persistence
    @EnvironmentObject var network: NetworkStatus
    @Binding var thread: EChat

    var body: some View {
        let navLink = NavigationLink("") {
            Chat(thread: $thread)
            .navigationTitle(thread.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !network.isConnected {
                        OfflineModeLabel()
                    }

                    AppButtons.search()
                }
            }
        }.opacity(0)
        
        HStack {
            chatAvatar
            VStack {
                HStack {
                    Text(thread.name ?? "").font(.headline)
                    Spacer()
                    Text(thread.lastMessageTime.userString).subheadline()
                }.padding(.bottom, 2)
                HStack {
                    lastMessagePreview
                    Spacer()
                    pinIcon
                }
            }
        }
        .background(navLink)
        .swipeActions(edge: .leading) {
            Button(!thread.pinned ? "Pin" : "Unpin") {
                thread.pinned.toggle()
                persistence.update(chat: thread)
            }.tint(.gray)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete") {
                persistence.delete(chat: thread)
            }.tint(.red)
        }
    }
    
    var chatAvatar: some View {
        Image("chatlist-chatgpt-logo")
            .resizable()
            .frame(width: 36, height: 36)
    }
    
    var lastMessagePreview: some View {
        let lastMessage = thread.sortedMessages
            .filter { $0.source == .USER }
            .last
        
        return Text(lastMessage?.text ?? "")
            .subheadline()
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    var pinIcon: some View {
        Group {
            if thread.pinned {
                Image("chatlist-pin-on")
                    .resizable()
                    .frame(width: 19.0, height: 16.0)
            }
        }
    }
}
