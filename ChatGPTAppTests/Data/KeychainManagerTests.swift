//
//  Tests.swift
//  ChatGPTAppTests
//
//  Created by Denis Babochenko on 25/04/2023.
//

import Foundation
import XCTest

@testable import ChatGPTApp

final class KeychainManagerTests: XCTestCase {

    var keychain = KeychainManagerImpl()
    
    override class func setUp() {
        var keychain = KeychainManagerImpl()
        if keychain.getApiToken() != nil {
            XCTAssertEqual(keychain.deleteApiToken(), .ok)
        }
        XCTAssertEqual(keychain.findApiToken(), .notFound)
    }
    
    func testSavesKey() throws {
        let someToken = "cool-token"
        let saveResult = keychain.saveApiToken(someToken)
        XCTAssertEqual(saveResult, .ok)

        let getResult = keychain.findApiToken()
        XCTAssertEqual(getResult, .ok(someToken))
    }
    
    func testDoesntSaveEmptyKey() throws {
        let saveResult = keychain.saveApiToken("")
        XCTAssertEqual(saveResult, .error("empty key"))
    }
}
