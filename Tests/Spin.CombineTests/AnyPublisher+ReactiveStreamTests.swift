//
//  AnyPublisher+ReactiveStreamTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Combine
import Spin_Combine
import Spin_Swift
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnyPublisher_ReactiveStreamTests: XCTestCase {
    private var disposeBag = [AnyCancellable]()

    func test_reactive_stream_is_subscribed_when_spin_is_called() {

        // Given: a reactive stream
        let exp = expectation(description: "spin expectation")
        var receivedValue = 0
        let sut = Just<Int>(1701)

        // When: spinning this reactive stream
        sut
            .handleEvents(receiveOutput: { value in
                receivedValue = value
                exp.fulfill()
            })
            .eraseToAnyPublisher()
            .spin()
            .disposed(by: &self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: The stream is executed and the value is fired
        XCTAssertEqual(receivedValue, 1701)
    }

    func test_reactive_stream_is_subscribed_after_a_trigger_when_spin_is_called() {

        // Given: a reactive stream
        let exp = expectation(description: "spin expectation")
        let sut = Just<Int>(1701)
        let trigger = PassthroughSubject<Void, Never>()
        var streamTime = 0.0
        var triggerTime = 0.0

        // When: spinning this reactive stream after a trigger
        sut
            .handleEvents(receiveOutput: { _ in
                streamTime = Date().timeIntervalSince1970
                exp.fulfill()
            })
            .eraseToAnyPublisher()
            .spin(after: trigger.handleEvents(receiveOutput: { _ in triggerTime = Date().timeIntervalSince1970 }))
            .disposed(by: &self.disposeBag)

        trigger.send(())

        waitForExpectations(timeout: 5)

        // Then: The stream is executed after the trigger has fired an event
        XCTAssert(triggerTime < streamTime)
    }

    func test_reactive_stream_makes_an_empty_stream_when_emptyStream_is_called() {
        // Given: an empty reactive stream
        var hasCompleted = false
        var hasReceivedEmptyValue = false
        let sut = AnyPublisher<Int, Never>.emptyStream()

        // When: subscribing to it
        _ = sut.collect().sink(receiveCompletion: { (_) in
            hasCompleted = true
        }) { values in
            hasReceivedEmptyValue = values.isEmpty
        }

        // Then: the stream directly completes without emitting events
        XCTAssertTrue(hasReceivedEmptyValue)
        XCTAssertTrue(hasCompleted)
    }
}
