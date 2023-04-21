//
//  ChatGPTAppTests.swift
//  ChatGPTAppTests
//
//  Created by Denis Babochenko on 17/04/2023.
//

import XCTest
@testable import ChatGPTApp

final class KeychainManagerTests: XCTestCase {

    func testSavesKey() throws {
        let someToken = "cool-token"

        let keychain = KeychainManager.shared
        if keychain.getApiToken() == .ok(someToken) {
            XCTAssertEqual(keychain.deleteApiToken(), .ok)
        }
        XCTAssertEqual(keychain.getApiToken(), .notFound)
        
        let saveResult = keychain.saveApiToken(someToken)
        XCTAssertEqual(saveResult, .ok)

        let getResult = keychain.getApiToken()
        XCTAssertEqual(getResult, .ok(someToken))
    }
}

final class ChatGPTAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
