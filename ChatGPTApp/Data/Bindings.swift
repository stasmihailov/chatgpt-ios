//
//  Bindings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/05/2023.
//

import SwiftUI

public struct BChat {
    private var persistence: Persistence
    private var obj: EChat
    
    var name: Binding<String>
    var model: Binding<String>
    var messages: Binding<Array<EMsg>>
    var pinned: Binding<Bool>
    
    init(persistence: Persistence, obj: EChat) {
        self.persistence = persistence
        self.obj = obj

        self.name = Binding(
            get: { obj.name },
            set: {
                var o = obj
                o.name = $0
                persistence.update(chat: o)
            }
        )
        self.model = Binding(
            get: { obj.model },
            set: {
                var o = obj
                o.model = $0
                persistence.update(chat: o)
            }
        )
        self.messages = Binding(
            get: { obj.messages },
            set: {
                var o = obj
                o.messages = $0
                persistence.update(chat: o)
            }
        )
        self.pinned = Binding(
            get: { obj.pinned },
            set: {
                var o = obj
                o.pinned = $0
                persistence.update(chat: o)
            }
        )
    }
}
