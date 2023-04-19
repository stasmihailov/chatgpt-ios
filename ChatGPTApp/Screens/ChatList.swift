//
//  ChatList.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct ChatLabel: View {
    var thread: ChatThreadData
    
    var body: some View {
        if thread.pinned {
            Image("chatlist-pin-on")
        } else {
        }
    }
}

struct ChatEntry: View {
    var thread: ChatThreadData
    
    var body: some View {
        let lastMessage = thread.messages.last
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
                    Text(thread.name).font(.headline)
                    Spacer()
                    Text(lastMessage?.time ?? "").subheadline()
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
    @State var threads: [ChatThreadData]
    var firstPinnedIdx: Int
    var firstOtherIdx: Int
    
    init(threads: [ChatThreadData]) {
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
                leading: ActionButton(),
                trailing: WriteButton())
        }
    }
}

struct ChatList_Previews: PreviewProvider {
    static var previews: some View {
        ChatList(threads: threads)
    }
}
