//
//  MoreTests.swift
//  ChatGPTAppTests
//
//  Created by Denis Babochenko on 22/04/2023.
//

import XCTest
import Foundation
import Combine
import LDSwiftEventSource

final class MoreTests: XCTestCase {
    
    func testStartRequestWithConfiguration() {
        let mockHandler = MockHandler()
        var config = EventSource.Config(handler: mockHandler, url: URL(string: "http://example.com")!)
        config.method = "REPORT"
        config.body = Data("test body".utf8)
        config.idleTimeout = 500.0
        config.lastEventId = "abc"
        config.headers = ["X-LD-Header": "def"]
        let es = EventSource(config: config)
        es.start()
        let handler = MockingProtocol.requested.expectEvent()
        XCTAssertEqual(handler.request.url, config.url)
        XCTAssertEqual(handler.request.httpMethod, config.method)
        XCTAssertEqual(handler.request.bodyStreamAsData(), config.body)
        XCTAssertEqual(handler.request.timeoutInterval, config.idleTimeout)
        XCTAssertEqual(handler.request.allHTTPHeaderFields?["Accept"], "text/event-stream")
        XCTAssertEqual(handler.request.allHTTPHeaderFields?["Cache-Control"], "no-cache")
        XCTAssertEqual(handler.request.allHTTPHeaderFields?["Last-Event-Id"], config.lastEventId)
        XCTAssertEqual(handler.request.allHTTPHeaderFields?["X-LD-Header"], "def")
        es.stop()
    }
}

enum ReceivedEvent: Equatable {
    case opened, closed, message(String, MessageEvent), comment(String), error(Error)

    static func == (lhs: ReceivedEvent, rhs: ReceivedEvent) -> Bool {
        switch (lhs, rhs) {
        case (.opened, .opened):
            return true
        case (.closed, .closed):
            return true
        case let (.message(typeLhs, eventLhs), .message(typeRhs, eventRhs)):
            return typeLhs == typeRhs && eventLhs == eventRhs
        case let (.comment(lhs), .comment(rhs)):
            return lhs == rhs
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}

class MockHandler: EventHandler {
    var events = EventSink<ReceivedEvent>()

    func onOpened() { events.record(.opened) }
    func onClosed() { events.record(.closed) }
    func onMessage(eventType: String, messageEvent: MessageEvent) { events.record(.message(eventType, messageEvent)) }
    func onComment(comment: String) { events.record(.comment(comment)) }
    func onError(error: Error) { events.record(.error(error)) }
}

struct EventSink<T> {
    private let semaphore = DispatchSemaphore(value: 0)
    private let queue = DispatchQueue(label: "EventSinkQueue." + UUID().uuidString)

    var receivedEvents: [T] = []

    mutating func record(_ event: T) {
        queue.sync { receivedEvents.append(event) }
        semaphore.signal()
    }

    mutating func expectEvent(maxWait: TimeInterval = 1.0) -> T {
        switch semaphore.wait(timeout: DispatchTime.now() + maxWait) {
        case .success:
            return queue.sync { receivedEvents.remove(at: 0) }
        case .timedOut:
            XCTFail("Expected mock handler to be called")
            return (nil as T?)!
        }
    }

    mutating func maybeEvent() -> T? {
        switch semaphore.wait(timeout: DispatchTime.now()) {
        case .success:
            return queue.sync { receivedEvents.remove(at: 0) }
        case .timedOut:
            return nil
        }
    }

    func expectNoEvent(within: TimeInterval = 0.1) {
        if case .success = semaphore.wait(timeout: DispatchTime.now() + within) {
            XCTFail("Expected no events in sink, found \(String(describing: receivedEvents.first))")
        }
    }
}

class RequestHandler {
    let proto: URLProtocol
    let request: URLRequest
    let client: URLProtocolClient?

    var stopped = false

    init(proto: URLProtocol, request: URLRequest, client: URLProtocolClient?) {
        self.proto = proto
        self.request = request
        self.client = client
    }

    func respond(statusCode: Int) {
        let headers = ["Content-Type": "text/event-stream; charset=utf-8", "Transfer-Encoding": "chunked"]
        let resp = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: headers)!
        client?.urlProtocol(proto, didReceive: resp, cacheStoragePolicy: .notAllowed)
    }

    func respond(didLoad: String) {
        respond(didLoad: Data(didLoad.utf8))
    }

    func respond(didLoad: Data) {
        client?.urlProtocol(proto, didLoad: didLoad)
    }

    func finishWith(error: Error) {
        client?.urlProtocol(proto, didFailWithError: error)
    }

    func finish() {
        client?.urlProtocolDidFinishLoading(proto)
    }

    func stop() {
        stopped = true
    }
}

class MockingProtocol: URLProtocol {
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canInit(with task: URLSessionTask) -> Bool { true }

    static var requested = EventSink<RequestHandler>()

    class func resetRequested() {
        requested = EventSink<RequestHandler>()
    }

    private var currentlyLoading: RequestHandler?

    override func startLoading() {
        let handler = RequestHandler(proto: self, request: request, client: client)
        currentlyLoading = handler
        MockingProtocol.requested.record(handler)
    }

    override func stopLoading() {
        currentlyLoading?.stop()
        currentlyLoading = nil
    }
}

extension URLRequest {
    func bodyStreamAsData() -> Data? {
        guard let bodyStream = self.httpBodyStream
        else { return nil }

        bodyStream.open()
        defer { bodyStream.close() }

        let bufSize: Int = 16
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: bufSize)
        defer { buf.deallocate() }

        var data = Data()
        while bodyStream.hasBytesAvailable {
            let readDat = bodyStream.read(buf, maxLength: bufSize)
            data.append(buf, count: readDat)
        }
        return data
    }
}
