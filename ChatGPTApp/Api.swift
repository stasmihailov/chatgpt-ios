//
//  OpenAIApi.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 20/04/2023.
//

import Foundation
import Combine

struct RuntimeError: Error {
    let error: String
    
    init(_ error: String) {
        self.error = error
    }
}

struct CompletionChunk: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    
    struct Choice: Decodable {
        let delta: Delta
        let index: Int
        let finish_reason: String?
    }
    
    struct Delta: Decodable {
        let content: String
    }
}

struct ApiError: Decodable {
    let error: ErrorDelegate
    
    struct ErrorDelegate: Decodable {
        let message: String
        let type: String
        let param: String?
        let code: String
    }
}

class EventSourceParser: NSObject, URLSessionDataDelegate {
    let messages = PassthroughSubject<String, RuntimeError>()
    
    static func parseChunks(from string: String) -> [String] {
        return string
            .components(separatedBy: "\n\n")
            .map { String($0.dropFirst(6)) }
            .compactMap { Coders.decode(messages: $0) }
            .flatMap { $0.choices }
            .map { $0.delta.content }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let stringData = String(data: data, encoding: .utf8)!

        let error = Coders.decode(error: stringData)
        if error != nil {
            print("sending error: " + stringData)
            messages.send(completion: .failure(RuntimeError(error!)))
            return
        }

        EventSourceParser.parseChunks(from: stringData)
            .forEach { messages.send($0) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            messages.send(completion: .failure(RuntimeError(error.localizedDescription)))
        } else {
            messages.send(completion: .finished)
        }
    }
}

protocol OpenAIApi {
    func chatCompletion(for chat: EChat, token: String) -> PassthroughSubject<String, RuntimeError>
}

class OpenAIApiWrapper: ObservableObject {
    var cancellables: [AnyCancellable] = []

    private let _chatCompletion: (EChat, String) -> PassthroughSubject<String, RuntimeError>
    
    init(_ delegate: OpenAIApi) {
        self._chatCompletion = delegate.chatCompletion
    }
    
    func cancelCurrent() {
        self.cancellables.forEach({ $0.cancel() })
        self.cancellables = []
    }
    
    func chatCompletion(for chat: EChat, token: String) -> PassthroughSubject<String, RuntimeError> {
        return _chatCompletion(chat, token)
    }
}

class OpenAIApiImpl: OpenAIApi {
    let keychain: KeychainManagerWrapper
    
    init(keychain: KeychainManagerWrapper) {
        self.keychain = keychain
    }
    
    func chatCompletion(for chat: EChat, token: String) -> PassthroughSubject<String, RuntimeError> {
        let eventSource = EventSourceParser()
        guard let token = keychain.getApiToken() else {
            eventSource.messages.send(completion: .failure(RuntimeError("cannot read token")))
            return eventSource.messages
        }
        let messages = eventSource.messages

        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        req.httpMethod = "POST"
        req.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let messagesJson = Coders.encode(messages: chat.messageList)
            let body: [String : Any] = [
                "model": chat.model!,
                "user": "masteryoda",
                "stream": true,
                "messages": messagesJson,
            ]

            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            messages.send(completion: .failure(RuntimeError("cannot serialise request")))
            return messages
        }

        let queue = OperationQueue()
        let dataTask = URLSession(configuration: .default, delegate: eventSource, delegateQueue: queue)
            .dataTask(with: req)
        dataTask.resume()
        
        return messages
    }
}

class Coders {
    public static func encode(role: EChatMsgSource) -> String {
        switch role {
        case .USER:
            return "user"
        case .ASSISTANT:
            return "assistant"
        }
    }
    
    public static func encode(messages: [EChatMsg]) -> [[String: String]] {
        let chatMessages: [[String: String]] = messages
            .sorted(by: { $0.time! < $1.time! })
            .map({ [
                "role": encode(role: $0.source),
                "content": $0.text!,
            ] })
            
        var allMessages: [[String: String]] = [
            [
                "role": "system",
                "content": "You are a helpful assistant."
            ]
        ]
        chatMessages.forEach({ allMessages.append($0) })
        
        return allMessages
    }
    
    public static func decode(error: String) -> String? {
        var errorObj = try? JSONDecoder().decode(ApiError.self,
                                                 from: error.data(using: .utf8)!)
        
        return errorObj?.error.code
    }
    
    public static func decode(messages: String) -> CompletionChunk? {
        try? JSONDecoder().decode(CompletionChunk.self,
                                 from: messages.data(using: .utf8)!)
    }
}
