//
//  CombineReducerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Spin_Combine
import Spin_Swift
import XCTest

final class CombineReducerTests: XCTestCase {

    func test_reducer_is_performed_on_default_executer_when_no_executer_is_specified() throws {
        // Given: an event stream switching on a specified Executer after being executed
        // and a Reducer applied after this event stream
        var reduceIsCalled = false
        let expectedExecuterName = "com.apple.main-thread"
        var receivedExecuterName = ""

        let inputStreamSchedulerQueueLabel = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = DispatchQueue(label: inputStreamSchedulerQueueLabel,
                                                 qos: .userInitiated,
                                                 attributes: .concurrent)

        let eventStream = Just("").receive(on: inputStreamScheduler).eraseToAnyPublisher()

        let reducerFunction = { (state: String, action: String) -> String in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return ""
        }

        // When: reducing without specifying an Executer for the reduce operation
        let sut = CombineReducer(reducer: reducerFunction)

        let recorder = sut.reducerOnExecuter("initialState", eventStream)
            .output(in: (0...1))
            .record()

        _ = try wait(for: recorder.completion, timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for CombineReducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reducer_is_performed_on_dedicated_executer_when_executer_is_specified() throws {
        // Given: a effect switching on a specified Executer after being executed
        var reduceIsCalled = false
        let expectedExecuterName = "REDUCER_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamSchedulerQueueLabel = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = DispatchQueue(label: inputStreamSchedulerQueueLabel,
                                                 qos: .userInitiated,
                                                 attributes: .concurrent)
        let reducerScheduler = DispatchQueue(label: expectedExecuterName,
                                             qos: .userInitiated,
                                             attributes: .concurrent).eraseToAnyScheduler()

        let eventStream = Just("").receive(on: inputStreamScheduler).eraseToAnyPublisher()

        let reducerFunction = { (state: String, action: String) -> String in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return ""
        }

        // When: reducing with specifying an Executer for the reduce operation
        let sut = CombineReducer(reducer: reducerFunction, on: reducerScheduler)

        let recorder = sut.reducerOnExecuter("initialState", eventStream)
            .output(in: (0...1))
            .record()

        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the effect
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }
}
