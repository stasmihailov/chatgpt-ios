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

protocol KeychainManager: ObservableObject {
    func findApiToken() -> GetTokenResult
    func getApiToken() -> String?
    func saveApiToken(_ tokenStr: String) -> ModifyTokenResult
    func deleteApiToken() -> ModifyTokenResult
}

class KeychainManagerWrapper: KeychainManager, ObservableObject {
    @Published var tokenExists: Bool = false

    private let _findApiToken: () -> GetTokenResult
    private let _getApiToken: () -> String?
    private let _saveApiToken: (String) -> ModifyTokenResult
    private let _deleteApiToken: () -> ModifyTokenResult

    init<T: KeychainManager>(_ wrapped: T) {
        _findApiToken = wrapped.findApiToken
        _getApiToken = wrapped.getApiToken
        _saveApiToken = wrapped.saveApiToken
        _deleteApiToken = wrapped.deleteApiToken
        
        resetState()
    }

    func findApiToken() -> GetTokenResult {
        return _findApiToken()
    }

    func getApiToken() -> String? {
        return _getApiToken()
    }

    func saveApiToken(_ tokenStr: String) -> ModifyTokenResult {
        resetState()
        return _saveApiToken(tokenStr)
    }

    func deleteApiToken() -> ModifyTokenResult {
        resetState()
        return _deleteApiToken()
    }
    
    func resetState() {
        tokenExists = getApiToken() != nil
    }
}

class KeychainManagerImpl: ObservableObject {
    private let queries = KeychainQueries()
}

extension KeychainManagerImpl: KeychainManager {
    func saveApiToken(_ tokenStr: String) -> ModifyTokenResult {
        if tokenStr.isEmpty {
            return .error("empty key")
        }
        
        let token = tokenStr.data(using: String.Encoding.utf8)!
        
        var result = findApiToken() == .notFound
        ? queries.doSave(token)
        : queries.doUpdate(token)

        guard result == errSecSuccess else {
            return .error(errorStr(from: result))
        }

        return .ok
    }
    
    func getApiToken() -> String? {
        let token = findApiToken()
        switch token {
        case .notFound:
            return nil
        case .error:
            return nil
        case .ok(let tokenStr):
            return tokenStr
        }
    }

    func findApiToken() -> GetTokenResult {
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
