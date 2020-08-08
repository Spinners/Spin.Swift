//
//  SignalProducer+ReactiveStreamTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import SpinReactiveSwift
import SpinCommon
import XCTest

final class SignalProducer_ReactiveStream: XCTestCase {
    private let disposables = CompositeDisposable()

    func test_reactive_stream_is_subscribed_when_spin_is_called() {

        // Given: a reactive stream
        let exp = expectation(description: "spin expectation")
        var receivedValue = 0
        let sut = SignalProducer<Int, Never>(value: 1701)

        // When: spinning this reactive stream
        sut
            .on(value: { value in
                receivedValue = value
                exp.fulfill()
            })
            .start()
            .add(to: self.disposables)

        waitForExpectations(timeout: 5)

        // Then: The stream is executed and the value is fired
        XCTAssertEqual(receivedValue, 1701)
    }

    func test_reactive_stream_makes_an_empty_stream_when_emptyStream_is_called() {
        // Given: an empty reactive stream
        let sut = SignalProducer<Int, Never>.emptyStream()

        // When: subscribing to it
        let events = sut.collect().first()

        // Then: the stream directly completes without emitting events
        XCTAssertEqual(events, Result<[Int], Never>.success([]))
    }
}
