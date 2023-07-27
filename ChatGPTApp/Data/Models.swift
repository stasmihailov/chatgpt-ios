//
//  EChat+CoreDataClass.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//
//

import Combine
import SwiftUI

class LWMsg: ObservableObject {
    @Published var text: String

    var time: Date
    var source: EMsgSource
    
    init(text: String = "", time: Date = Date(), source: EMsgSource) {
        self.text = text
        self.time = time
        self.source = source
    }
    
    func reset(source: EMsgSource) {
        self.text = ""
        self.time = Date()
        self.source = source
    }
    
    static func from(_ chatMsg: EMsg) -> LWMsg {
        var msg = LWMsg(source: chatMsg.source)
        msg.text = chatMsg.text
        msg.time = chatMsg.time
        
        return msg
    }
}

public struct EChat: Identifiable, Codable, Hashable {
    public var id: String
    var model: String
    var name: String
    var pinned: Bool
    var messages: [EMsg]
    
    var lastMessageTime: Date { get { return self.messages.last?.time ?? Date.distantPast } }
    var sortedMessages: [EMsg] { get { self.messages.sorted(by: { $0.time < $1.time }) } }

    func bind(to persistence: Persistence) -> BChat {
        return BChat(persistence: persistence, obj: self)
    }
    
    static func new() -> EChat {
        return EChat(
            id: "...",
            model: "gpt-3.5-turbo",
            name: "Empty chat",
            pinned: false,
            messages: []
        )
    }

    public static func ==(lhs: EChat, rhs: EChat) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct EMsg: Identifiable, Codable, Hashable {
    public var id: String
    var source: EMsgSource
    var text: String
    var time: Date
    
    init(source: EMsgSource, text: String) {
        self.id = "..."
        self.source = source
        self.text = text
        self.time = Date()
    }
    
    public static func ==(lhs: EMsg, rhs: EMsg) -> Bool {
        return lhs.id == rhs.id
    }
}

enum EMsgSource: String, Codable {
    case USER, ASSISTANT
}
