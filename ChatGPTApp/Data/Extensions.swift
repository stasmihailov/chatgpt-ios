//
//  Extensions.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 17/05/2023.
//

import Foundation

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
