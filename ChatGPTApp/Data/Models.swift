//
//  EChat+CoreDataClass.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//
//

import Foundation
import CoreData
import SwiftUI

class LWMsg: ObservableObject {
    @Published var text: String

    var time: Date
    var source: EChatMsgSource
    
    init(text: String = "", time: Date = Date(), source: EChatMsgSource) {
        self.text = text
        self.time = time
        self.source = source
    }
    
    func reset(source: EChatMsgSource) {
        self.text = ""
        self.time = Date()
        self.source = source
    }
    
    static func from(_ chatMsg: EChatMsg) -> LWMsg {
        var msg = LWMsg(source: chatMsg.source)
        msg.text = chatMsg.text!
        msg.time = chatMsg.time!
        
        return msg
    }
}

@objc(EChat)
public class EChat: NSManagedObject {
    var nextMessage: EChatMsg? = nil
    var modelBinding: Binding<String> {
        Binding<String>(
            get: { self.model ?? "" },
            set: { self.model = $0 }
        )
    }
    
    var messageList: [EChatMsg] {
        get {
            return self.messages?.compactMap { $0 as? EChatMsg } as! [EChatMsg]
        }
    }
    
    func newMessage(source: EChatMsgSource, text: String) -> EChatMsg {
        let ctx = Persistence.shared.context
        
        let msg = EChatMsg(context: ctx)
        msg.source = source
        msg.text = text
        msg.time = Date()
        msg.chat = self
        
        do {
            try ctx.save()
        } catch {
            // on error
        }
        
        return msg
    }

    func addResponse(response: LWMsg) -> EChatMsg {
        let ctx = Persistence.shared.context
        
        let msg = EChatMsg(context: ctx)
        msg.source = response.source
        msg.text = response.text
        msg.time = response.time
        msg.chat = self
        
        nextMessage = msg
        
        do {
            try ctx.save()
        } catch {
            // on error
        }

        return msg
    }
}

enum EChatMsgSource: String {
    case USER, ASSISTANT;
}

@objc(EChatMsg)
public class EChatMsg: NSManagedObject {
    var source: EChatMsgSource {
        get {
            return EChatMsgSource(rawValue: self.sourceRaw!)!
        } set {
            self.sourceRaw = newValue.rawValue
        }
    }
}

public class EChats: ObservableObject {
    @Published var chats: [EChat]
    
    init(chats: [EChat]) {
        self.chats = chats
    }
}
