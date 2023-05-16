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

    static func new() -> EChat {
        return EChat(
            id: "...",
            model: "gpt-3.5-turbo",
            name: "Empty chat",
            pinned: false,
            messages: []
        )
    }
    
    var lastMessageTime: Date {
        get {
            return self.messages.last?.time ?? Date.distantPast
        }
    }
    
    var sortedMessages: [EMsg] {
    get {
            self.messages.sorted(by: { $0.time < $1.time })
        }
    }

    public static func ==(lhs: EChat, rhs: EChat) -> Bool {
        return lhs.id == rhs.id
    }
}

fileprivate let decoder = JSONDecoder()
fileprivate let encoder = JSONEncoder()

extension EChat {
    func encode() -> [String: Any] {
        guard let data = try? encoder.encode(self) else {
            print("Error: cannot convert EChat to data.")
            return [:]
        }
        
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            print("Error: cannot convert data to dictionary.")
            return [:]
        }
    
        return dictionary
    }
    
    static func decode(from data: [String: Any]) -> EChat? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            print("Error: cannot convert dictionary to data.")
            return nil
        }

        guard let chat = try? decoder.decode(EChat.self, from: jsonData) else {
            print("Error: cannot decode data to EChat.")
            return nil
        }
        
        return chat
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

fileprivate let userDateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "dd MMM"
    return fmt
}()

fileprivate let userTimeFormatter = {
    let fmt = DateFormatter()
    fmt.timeStyle = .short
    return fmt
}()

extension Date {
    var userString: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let isBeforeToday = calendar.compare(self, to: today, toGranularity: .day) == .orderedAscending
        if isBeforeToday {
            return userDateFormatter.string(from: self)
        } else {
            return userTimeFormatter.string(from: self)
        }
    }
}
