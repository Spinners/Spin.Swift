//
//  ReducerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import SpinCombine
import SpinCommon
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class ReducerTests: XCTestCase {

    private var disposeBag = [AnyCancellable]()

    func test_reducer_is_performed_on_default_executer_when_no_executer_is_specified() throws {
        // Given: an event stream switching on a specified Executer after being executed
        // and a Reducer applied after this event stream
        let exp = expectation(description: "default executer for reducer")
        var reduceIsCalled = false
        let expectedExecuterName = "com.apple.main-thread"
        var receivedExecuterName = ""

        let inputStreamSchedulerQueueLabel = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = DispatchQueue(label: inputStreamSchedulerQueueLabel,
                                                 qos: .userInitiated)

        let eventStream = Just("").receive(on: inputStreamScheduler).eraseToAnyPublisher()

        let reducerFunction = { (state: String, action: String) -> String in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            exp.fulfill()
            return ""
        }

        // When: reducing without specifying an Executer for the reduce operation
        let sut = ScheduledReducer(reducerFunction)
        let scheduledReducer = sut.scheduledReducer(with: "initialState")

        scheduledReducer(eventStream)
            .output(in: (0...1))
            .subscribe()
            .disposed(by: &self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for Reducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reducer_is_performed_on_dedicated_executer_when_executer_is_specified() throws {
        // Given: a effect switching on a specified Executer after being executed
        let exp = expectation(description: "default executer for reducer")
        var reduceIsCalled = false
        let expectedExecuterName = "REDUCER_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamSchedulerQueueLabel = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = DispatchQueue(label: inputStreamSchedulerQueueLabel,
                                                 qos: .userInitiated)
        let reducerScheduler = DispatchQueue(label: expectedExecuterName,
                                             qos: .userInitiated).eraseToAnyScheduler()

        let eventStream = Just("").receive(on: inputStreamScheduler).eraseToAnyPublisher()

        let reducerFunction = { (state: String, action: String) -> String in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            exp.fulfill()
            return ""
        }

        // When: reducing with specifying an Executer for the reduce operation
        let sut = ScheduledReducer(reducerFunction, on: reducerScheduler)
        let scheduledReducer = sut.scheduledReducer(with: "initialState")

        scheduledReducer(eventStream)
            .output(in: (0...1))
            .subscribe()
            .disposed(by: &self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the effect
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }
}
