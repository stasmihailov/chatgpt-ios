//
//  ChatListCell.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 30/04/2023.
//

import SwiftUI

struct ChatListCell: View {
    @ObservedObject var thread: EChat

    var body: some View {
        let lastMessage = thread.messageList.last
        let navLink = NavigationLink("") {
            Chat(thread: thread)
        }.opacity(0)
        
        HStack {
            chatAvatar
            VStack {
                HStack {
                    Text(thread.name!).font(.headline)
                    Spacer()
                    Text(lastMessage?.lastTimeString ?? "").subheadline()
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
                Persistence.shared.saveContext()
            }.tint(.gray)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete") {
                Persistence.shared.context.delete(thread)
                Persistence.shared.saveContext()
            }.tint(.red)
        }
    }
    
    var chatAvatar: some View {
        Image("chatlist-chatgpt-logo")
            .resizable()
            .frame(width: 36, height: 36)
    }
    
    var lastMessagePreview: some View {
        let lastMessage = thread.messageList.last
        
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
