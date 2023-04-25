//
//  DataTests.swift
//  ChatGPTAppTests
//
//  Created by Denis Babochenko on 25/04/2023.
//

import Foundation
import XCTest

@testable import ChatGPTApp

final class KeychainManagerTests: XCTestCase {

    func testSavesKey() throws {
        let someToken = "cool-token"

        let keychain = KeychainManager.shared
        if keychain.findApiToken() == .ok(someToken) {
            XCTAssertEqual(keychain.deleteApiToken(), .ok)
        }
        XCTAssertEqual(keychain.findApiToken(), .notFound)
        
        let saveResult = keychain.saveApiToken(someToken)
        XCTAssertEqual(saveResult, .ok)

        let getResult = keychain.findApiToken()
        XCTAssertEqual(getResult, .ok(someToken))
    }
}
