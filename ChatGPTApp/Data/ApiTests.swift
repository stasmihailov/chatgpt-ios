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

final class ApiTests: XCTestCase {
    var cancellables: [AnyCancellable] = []

    func testCompletion() throws {
        let keychain = KeychainManagerWrapper(KeychainManagerImpl())
        let api = OpenAIApiImpl(keychain: keychain)

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

        var actualValues: [String] = []
        let expectation = XCTestExpectation(description: "Waiting for all messages")
        api.chatCompletion(for: chat, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                    break
                case .failure(let err):
                    XCTFail(err.error)
                    break
                }
            }, receiveValue: { value in
                actualValues.append(value)
            }).store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(actualValues, ["cock"])
    }

    override func tearDownWithError() throws {
        cancellables.forEach({ $0.cancel() })
    }
}
