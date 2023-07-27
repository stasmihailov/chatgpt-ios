//
//  PersistenceTests.swift
//  ChatGPTAppTests
//
//  Created by Denis Babochenko on 29/04/2023.
//

import Foundation
import XCTest

@testable import ChatGPTApp

final class PersistenceTests: XCTestCase {
    let persistence = Persistence.shared
    
    func testDeleteEverything() throws {
        var chat = persistence.newChat()
        XCTAssertEqual(persistence.fetchChats(), [chat])
        
        persistence.deleteAllEntities()
        XCTAssertEqual(persistence.fetchChats(), [])
        
        chat = persistence.newChat()
        XCTAssertEqual(persistence.fetchChats(), [chat])
    }
}
