//
//  ApiTests.swift
//  ChatGPTAppTests
//
//  Created by Denis Babochenko on 25/04/2023.
//

import Foundation
import XCTest
import Combine

@testable import ChatGPTApp

final class EventSourceTests: XCTestCase {
    
    func testGetTokensFromData() throws {
        let data = "data: {\"id\":\"chatcmpl-78TRGFu6qPHzuBGJBivNaM5RWDNTw\",\"object\":\"chat.completion.chunk\",\"created\":1682254142,\"model\":\"gpt-3.5-turbo-0301\",\"choices\":[{\"delta\":{\"role\":\"assistant\"},\"index\":0,\"finish_reason\":null}]}\n\ndata: {\"id\":\"chatcmpl-78TRGFu6qPHzuBGJBivNaM5RWDNTw\",\"object\":\"chat.completion.chunk\",\"created\":1682254142,\"model\":\"gpt-3.5-turbo-0301\",\"choices\":[{\"delta\":{\"content\":\"Hello\"},\"index\":0,\"finish_reason\":null}]}\n\ndata: {\"id\":\"chatcmpl-78TRGFu6qPHzuBGJBivNaM5RWDNTw\",\"object\":\"chat.completion.chunk\",\"created\":1682254142,\"model\":\"gpt-3.5-turbo-0301\",\"choices\":[{\"delta\":{\"content\":\" there\"},\"index\":0,\"finish_reason\":null}]}\n\n"
        
        let chunks = EventSourceParser.parseChunks(from: data)
        XCTAssertEqual(chunks, ["Hello", " there"])
    }
}

class ApiTests: XCTestCase {
    var cancellables: [AnyCancellable]
    var keychain: KeychainManagerWrapper
    var api: OpenAIApi
    
    override init() {
        cancellables = []
        keychain = KeychainManagerWrapper(KeychainManagerImpl())
        api = OpenAIApiImpl(keychain: keychain)

        super.init()
    }

    func testCompletion() throws {
        guard let token = keychain.getApiToken() else {
            throw RuntimeError("cannot read token")
        }
    
        let ctx = Persistence.shared.context
        let msg = EChatMsg(context: ctx)
        msg.source = .USER
        msg.text = "How are you today?"
        
        let chat = EChat(context: ctx)
        chat.model = "gpt-3.5-turbo"
        chat.messages = [
            msg
        ]
        
        let semaphore = DispatchSemaphore(value: 0)

        var actualValues: [String] = []
        api.chatCompletion(for: chat, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                print("leaving the subscriber")
                semaphore.signal()
            }, receiveValue: { value in
                print("value: " + value)
                actualValues.append(value)
            }).store(in: &cancellables)

        let awaited = semaphore.wait(timeout: .now() + 10)
        guard awaited == .success else {
            throw RuntimeError("timed out while waiting for OpenAPI response")
        }
        
        XCTAssertEqual(actualValues, ["cock"])
    }

    override func tearDownWithError() throws {
        cancellables.forEach({ $0.cancel() })
    }
}
