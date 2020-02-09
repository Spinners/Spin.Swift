//
//  ReactiveReducerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Spin_ReactiveSwift
import ReactiveSwift
import XCTest

final class ReactiveReducerTests: XCTestCase {

    private let disposeBag = CompositeDisposable()

    func test_reducer_is_performed_on_default_executer_when_no_executer_is_specified() {
        // Given: an event stream switching on a specified Executer after being executed
        // and a Reducer applied after this event stream
        let exp = expectation(description: "default executer for reducer")
        var reduceIsCalled = false
        let expectedExecuterName = "com.apple.main-thread"
        var receivedExecuterName = ""

        let inputStreamScheduler = QueueScheduler(qos: .background, name: "INPUT_STREAM_QUEUE_\(UUID().uuidString)")

        let eventStream = SignalProducer<String, Never>(value: "").observe(on: inputStreamScheduler)

        let reducerFunction = { (state: String, action: String) -> String in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            exp.fulfill()
            return ""
        }

        // When: reducing without specifying an Executer for the reduce operation
        let sut = ReactiveReducer(reducer: reducerFunction)

        _ = sut.reducerOnExecuter("initialState", eventStream)
            .take(first: 2)
            .start()
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for ReactiveReducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reducer_is_performed_on_dedicated_executer_when_executer_is_specified() {
        // Given: an effect switching on a specified Executer after being executed
        let exp = expectation(description: "default executer for reducer")
        var reduceIsCalled = false
        let expectedExecuterName = "REDUCER_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamScheduler = QueueScheduler(qos: .background, name: "INPUT_STREAM_QUEUE_\(UUID().uuidString)")
        let reducerScheduler = QueueScheduler(qos: .background, name: expectedExecuterName)

        let eventStream = SignalProducer<String, Never>(value: "").observe(on: inputStreamScheduler)

        let reducerFunction = { (state: String, action: String) -> String in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            exp.fulfill()
            return ""
        }

        // When: reducing with specifying an Executer for the reduce operation
        let sut = ReactiveReducer(reducer: reducerFunction, on: reducerScheduler)

        _ = sut.reducerOnExecuter("initialState", eventStream)
            .take(first: 2)
            .start()
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the effect
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }
}
