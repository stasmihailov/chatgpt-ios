//
//  ChatList.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct ChatThread {
    var id: String;
    var name: String;
    var messages: [ChatMessage];
    var pinned: Bool;
}

struct ChatLabel: View {
    var thread: ChatThread
    
    var body: some View {
        if thread.pinned {
            Image("chatlist-pin-on")
        } else {
        }
    }
}

struct ChatEntry: View {
    var thread: ChatThread
    
    var body: some View {
        let lastMessage = thread.messages.last
        let nav = NavigationLink("") {
            Chat(thread: thread)
        }.opacity(0)
        
        HStack {
            Image("chatlist-chatgpt-logo")
                .resizable()
                .frame(width: 36, height: 36)
            VStack {
                HStack {
                    Text(thread.name)
                        .font(.headline)
                    Spacer()
                    Text(lastMessage?.time ?? "")
                        .subheadline()
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
    let threads: [ChatThread]
    let firstPinnedIdx: Int
    let firstOtherIdx: Int
    
    init(threads: [ChatThread]) {
        self.threads = threads
        
        let firstPinnedIdx = threads.enumerated().first { $0.element.pinned == true }?.offset ?? -1
        let firstOtherIdx = threads.enumerated().first { $0.element.pinned == false }?.offset ?? -1
        
        if (firstOtherIdx >= 0 && firstOtherIdx >= 0) {
            self.firstPinnedIdx = firstPinnedIdx
            self.firstOtherIdx = firstOtherIdx
        } else {
            self.firstPinnedIdx = -1
            self.firstOtherIdx = -1
        }
    }
    
    var body: some View {
        let chat = VStack {
            List {
                ForEach(0..<threads.count) { idx in
                    if idx == firstPinnedIdx {
                        Text("Pinned Chats").subheadline()
                    } else if idx == firstOtherIdx {
                        Text("Other Chats").subheadline()
                    }

                    ChatEntry(thread: threads[idx])
                }
            }.listStyle(PlainListStyle())
        }
        
        NavigationView {
            chat
            .navigationBarTitle("Chats", displayMode: .inline)
            .navigationBarItems(
                leading: Text("Edit")
                    .foregroundColor(AppColors.accent),
                trailing: Image(systemName: "square.and.pencil")
                    .foregroundColor(AppColors.accent))
        }
    }
}

struct ChatList_Previews: PreviewProvider {
    static var previews: some View {
        ChatList(threads: threads)
    }
}
