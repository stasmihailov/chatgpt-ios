//
//  KeychainManager.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 21/04/2023.
//

import Security
import Foundation

enum ModifyTokenResult: Equatable {
    case ok
    case error(String)
}

enum GetTokenResult: Equatable {
    case ok(String)
    case notFound
    case error(String)
}

class KeychainQueries {
    private let appTag = "com.babochenko.chatgpt"

    func query(_ data: [String: Any]) -> [String: Any] {
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: appTag,
        ]

        return baseQuery.merging(data, uniquingKeysWith: { (c, _) in c })
    }
    
    func doUpdate(_ token: Data) -> OSStatus {
        let updates: [String: Any] = [
            kSecValueData as String: token,
        ]
        return SecItemUpdate(query([:]) as CFDictionary, updates as CFDictionary)
    }

    func doSave(_ token: Data) -> OSStatus {
        let query: [String: Any] = query([
            kSecValueData as String: token,
        ])
        return SecItemAdd(query as CFDictionary, nil)
    }
}

class KeychainManager {
    static let shared = KeychainManager()
    
    private let queries = KeychainQueries()
    
    func saveApiToken(_ tokenStr: String) -> ModifyTokenResult {
        let token = tokenStr.data(using: String.Encoding.utf8)!
        
        var result = getApiToken() == .notFound
        ? queries.doSave(token)
        : queries.doUpdate(token)

        guard result == errSecSuccess else {
            return .error(errorStr(from: result))
        }
        
        return .ok
    }
    
    func getApiToken() -> GetTokenResult {
        let query: [String: Any] = queries.query([
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ])

        var apiKey: AnyObject?
        let result = SecItemCopyMatching(query as CFDictionary, &apiKey)
        guard result != errSecItemNotFound else {
            return .notFound
        }
        guard result == errSecSuccess else {
            return .error(errorStr(from: result))
        }
        guard let apiKeyData = apiKey as? Data else {
            return .error("Cannot cast apiKey to Data?")
        }
        
        return .ok(String(decoding: apiKeyData, as: UTF8.self))
    }
    
    func deleteApiToken() -> ModifyTokenResult {
        let result = SecItemDelete(queries.query([:]) as CFDictionary)
        guard result == errSecSuccess else {
            return .error(errorStr(from: result))
        }
        
        return .ok
    }

    private func errorStr(from result: OSStatus) -> String {
        let resultString = SecCopyErrorMessageString(result, nil)
        return resultString as? String ?? String(result)
    }
}
