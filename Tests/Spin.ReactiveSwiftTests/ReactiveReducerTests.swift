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

    func test_reduce_is_performed_on_default_executer_when_no_executer_is_specified() {
        // Given: a feedback switching on a specified Executer after being executed
        let exp = expectation(description: "default executer for reducer")
        var reduceIsCalled = false
        let expectedExecuterName = "com.apple.main-thread"
        var receivedExecuterName = ""

        let inputStreamScheduler = QueueScheduler(qos: .background, name: "INPUT_STREAM_QUEUE_\(UUID().uuidString)")

        let feedback = ReactiveFeedback(effect: { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            return inputs.map { _ in return "" }.observe(on: inputStreamScheduler)
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            exp.fulfill()
            return 0
        }

        // When: reducing without specifying an Executer for the reduce operation
        _ = ReactiveReducer(reducer: reducerFunction)
            .apply(on: 0, after: feedback.effect)
            .take(first: 2)
            .spin()
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for ReactiveReducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reduce_is_performed_on_dedicated_executer_when_executer_is_specified() {
        // Given: a feedback switching on a specified Executer after being executed
        var reduceIsCalled = false
        let expectedExecuterName = "REDUCER_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamScheduler = QueueScheduler(qos: .background, name: "INPUT_STREAM_QUEUE_\(UUID().uuidString)")
        let reducerScheduler = QueueScheduler(qos: .background, name: expectedExecuterName)

        let feedback = ReactiveFeedback(effect: { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            return inputs.map { _ in return "" }.observe(on: inputStreamScheduler)
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return 0
        }

        // When: reducing with specifying an Executer for the reduce operation
        _ = ReactiveReducer(reducer: reducerFunction, on: reducerScheduler)
            .apply(on: 0, after: feedback.effect)
            .take(first: 2)
            .collect()
            .first()

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the feedback
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_initialState_is_the_first_state_given_to_the_feedbacks() {
        // Given: 2 feedbacks
        let initialState = 1701
        var receivedInitialStateInFeedbackA = 0
        var receivedInitialStateInFeedbackB = 0

        let feedbackA = ReactiveFeedback(effect: { (input: Int) -> SignalProducer<String, Never> in
            receivedInitialStateInFeedbackA = input
            return SignalProducer<String, Never>(value: "")
        })

        let feedbackB = ReactiveFeedback(effect: { (input: Int) -> SignalProducer<String, Never> in
            receivedInitialStateInFeedbackB = input
            return SignalProducer<String, Never>(value: "")
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing the feedbacks
        _ = ReactiveReducer(reducer: reducerFunction)
            .apply(on: initialState, after: ReactiveFeedback(feedbacks: feedbackA, feedbackB).effect)
            .take(first: 1)
            .collect()
            .first()

        // Then: the initial states received in the feedbacks are the one specified in the Reducer
        XCTAssertEqual(receivedInitialStateInFeedbackA, initialState)
        XCTAssertEqual(receivedInitialStateInFeedbackB, initialState)
    }

    func test_reduce_with_an_array_of_streams_preserves_the_streams() throws {
        // Given: 2 feedback streams
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false

        let feedbackAFunction = { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            feedbackAIsCalled = true
            return SignalProducer(value: "")
        }
        let feedbackBFunction = { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            feedbackBIsCalled = true
            return SignalProducer(value: "")
        }

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing with those feedback streams
        _ = try ReactiveReducer(reducer: reducerFunction)
            .apply(on: 0, after: [feedbackAFunction, feedbackBFunction])
            .take(first: 1)
            .collect()
            .first()?
            .get()

        // Then: the 2 feedbacks are executed
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
    }
}
