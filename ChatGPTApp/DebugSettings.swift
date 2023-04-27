////
////  DebugSettings2.swift
////  ChatGPTApp
////
////  Created by Denis Babochenko on 25/04/2023.
////
//
//import Foundation
//import Combine
//
//@testable import ChatGPTApp
//
//class MockKeychainManager {
//    private var apiToken: String?
//}
//
//extension MockKeychainManager: KeychainManager {
//    func findApiToken() -> GetTokenResult {
//        return apiToken.map(GetTokenResult.ok) ?? .notFound
//    }
//
//    func getApiToken() -> String? {
//        return apiToken
//    }
//
//    func saveApiToken(_ tokenStr: String) -> ModifyTokenResult {
//        self.apiToken = tokenStr
//        return .ok
//    }
//
//    func deleteApiToken() -> ModifyTokenResult {
//        self.apiToken = nil
//        return .ok
//    }
//}
//
//class MockOpenAIApi {
//    private var nextMessages: [String]?
//}
//
//extension MockOpenAIApi: OpenAIApi {
//    func chatCompletion(for chat: EChat, token: String) -> PassthroughSubject<String, RuntimeError> {
//        var response = PassthroughSubject<String, RuntimeError>()
//
//        if nextMessages == nil {
//            print("nextMessages is nil")
//            return response
//        }
//
//        nextMessages?.forEach(response.send)
//        nextMessages = []
//
//        return response
//    }
//}
