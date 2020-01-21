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

    func test_reduce_is_performed_on_default_executer_when_no_executer_is_specified() throws {
        // Given: a feedback switching on a specified Executer after being executed
        var reduceIsCalled = false
        let expectedExecuterName = "com.apple.main-thread"
        var receivedExecuterName = ""

        let inputStreamSchedulerQueueLabel = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = DispatchQueue(label: inputStreamSchedulerQueueLabel,
                                                 qos: .userInitiated,
                                                 attributes: .concurrent)

        let feedback = DispatchQueueCombineFeedback<Int, String>(effect: { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            return inputs.map { _ in return "" }.receive(on: inputStreamScheduler).eraseToAnyPublisher()
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return 0
        }

        // When: reducing without specifying an Executer for the reduce operation
        let recorder = CombineReducer(reducer: reducerFunction)
            .apply(on: 0, after: feedback.effect)
            .output(in: (0...1))
            .record()

        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for CombineReducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reduce_is_performed_on_dedicated_executer_when_executer_is_specified() throws {
        // Given: a feedback switching on a specified Executer after being executed
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

        let feedback = DispatchQueueCombineFeedback<Int, String>(effect: { (inputs: AnyPublisher<Int, Never>) in
            return inputs.map { _ in return "" }.receive(on: inputStreamScheduler).eraseToAnyPublisher()
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return 0
        }

        // When: reducing with specifying an Executer for the reduce operation
        let recorder = CombineReducer(reducer: reducerFunction, on: reducerScheduler)
            .apply(on: 0, after: feedback.effect)
            .output(in: (0...1))
            .record()

        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the feedback
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_initialState_is_the_first_state_given_to_the_feedbacks() throws {
        // Given: 2 feedbacks
        let initialState = 1701
        var receivedInitialStateInFeedbackA = 0
        var receivedInitialStateInFeedbackB = 0

        let feedbackA = DispatchQueueCombineFeedback<Int, String>(effect: { (input: Int) -> AnyPublisher<String, Never> in
            receivedInitialStateInFeedbackA = input
            return Just<String>("").eraseToAnyPublisher()
        })

        let feedbackB = DispatchQueueCombineFeedback<Int, String>(effect: { (input: Int) -> AnyPublisher<String, Never> in
            receivedInitialStateInFeedbackB = input
            return Just<String>("").eraseToAnyPublisher()
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing the feedbacks
        let recorder = CombineReducer(reducer: reducerFunction)
            .apply(on: initialState, after: DispatchQueueCombineFeedback(feedbacks: feedbackA, feedbackB).effect)
            .first()
            .record()

        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the initial states received in the feedbacks are the one specified in the Reducer
        XCTAssertEqual(receivedInitialStateInFeedbackA, initialState)
        XCTAssertEqual(receivedInitialStateInFeedbackB, initialState)
    }

    func test_reduce_with_an_array_of_streams_preserves_the_streams() throws {
        // Given: 2 feedback streams
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false

        let feedbackAFunction = { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            feedbackAIsCalled = true
            return Just("").eraseToAnyPublisher()
        }
        let feedbackBFunction = { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            feedbackBIsCalled = true
            return Just("").eraseToAnyPublisher()
        }

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing with those feedback streams
        let recorder = CombineReducer(reducer: reducerFunction)
            .apply(on: 0, after: [feedbackAFunction, feedbackBFunction])
            .output(in: (0...1))
            .record()

        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the 2 feedbacks are executed
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
    }
}
