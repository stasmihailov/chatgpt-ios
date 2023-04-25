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

    func prepareNextMessage(source: EChatMsgSource) -> EChatMsg {
        let ctx = Persistence.shared.context
        
        let msg = EChatMsg(context: ctx)
        msg.source = source
        msg.text = ""
        msg.time = Date()
        msg.chat = self
        
        nextMessage = msg
        
        return msg
    }
    
    func saveCurrentMessage() {
        let ctx = Persistence.shared.context
        
        do {
            try ctx.save()
        } catch {
            // on error
        }
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
