//
//  ChatList.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct ChatLabel: View {
    var thread: EChat
    
    var body: some View {
        if thread.pinned {
            Image("chatlist-pin-on")
        } else {
        }
    }
}

struct ChatEntry: View {
    @ObservedObject var thread: EChat

    var body: some View {
        let lastMessage = thread.messageList.last
        let nav = NavigationLink("") {
            Chat(thread: thread)
        }.opacity(0)
        
        let chatAvatar = Image("chatlist-chatgpt-logo")
            .resizable()
            .frame(width: 36, height: 36)
        
        HStack {
            chatAvatar
            VStack {
                HStack {
                    Text(thread.name!).font(.headline)
                    Spacer()
                    Text(lastMessage?.time?.timeString() ?? "").subheadline()
                }.padding(.bottom, 2)
                HStack {
                    Text(lastMessage?.text ?? "")
                        .subheadline()
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    ChatLabel(thread: thread)
                }
            }
        }.background(nav)
    }
}

struct ChatList: View {
    @EnvironmentObject var chats: EChats

    var body: some View {
        let chatList = chats.chats.enumerated()

        var firstPinnedIdx = chatList.first { $0.element.pinned }?.offset ?? -1
        var firstOtherIdx = firstPinnedIdx < 0 ? -1 : chatList.first { !$0.element.pinned }?.offset ?? -1
        
        let chat = VStack {
            List {
                ForEach(0..<chats.chats.count) { idx in
                    if idx == firstPinnedIdx {
                        Text("Pinned Chats").subheadline()
                    } else if idx == firstOtherIdx {
                        Text("Other Chats").subheadline()
                    }

                    ChatEntry(thread: chats.chats[idx])
                }
            }.listStyle(PlainListStyle())
        }
        
        NavigationView {
            chat
            .navigationBarTitle("Chats", displayMode: .inline)
            .navigationBarItems(
                leading: ActionButton(),
                trailing: WriteButton() {
                    
                })
        }
    }
}
//
//struct ChatList_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatList()
//            .environmentObject(EChat())
//    }
//}
