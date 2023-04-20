//
//  State.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//

import SwiftUI

enum TChatMsgRole {
    case USER, ASSISTANT;
}

class TChat: ObservableObject {
    var id: String;
    @Published var name: String;
    @Published var model: String;
    @Published var messages: [TChatMsg];
    @Published var pinned: Bool;
    
    init(id: String, name: String, model: String, messages: [TChatMsg], pinned: Bool) {
        self.id = id
        self.name = name
        self.model = model
        self.messages = messages
        self.pinned = pinned
    }
}

struct TChatMsg {
    var id: String;
    var source: TChatMsgRole;
    var time: String;
    var text: String;
}

class TChats: ObservableObject {
    @Published var chats: [TChat]
    
    init(chats: [TChat]) {
        self.chats = chats
    }
}
