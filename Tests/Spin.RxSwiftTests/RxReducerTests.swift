//
//  RxReducerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxBlocking
import RxSwift
import Spin_RxSwift
import XCTest

final class RxReducerTests: XCTestCase {

    func test_reduce_is_performed_on_current_executer_when_no_executer_is_specified() {
        // Given: a feedback switching on a specified Executer after being executed
        var reduceIsCalled = false
        let expectedExecuterName = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: expectedExecuterName,
                                                                                         qos: .userInitiated))

        let feedback = RxFeedback(feedback: { (inputs: Observable<Int>) -> Observable<String> in
            return Observable<String>.just("").observeOn(inputStreamScheduler)
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return 0
        }

        // When: reducing without specifying an Executer for the reduce operation
        _ = RxReducer(reducer: reducerFunction)
            .reduce(initialState: 0, feedback: feedback.feedbackStream)
            .take(2)
            .toBlocking()
            .materialize()

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for RxReducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reduce_is_performed_on_dedicated_executer_when_executer_is_specified() {
        // Given: a feedback switching on a specified Executer after being executed
        var reduceIsCalled = false
        let expectedExecuterName = "REDUCER_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamSchedulerQueueLabel = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: inputStreamSchedulerQueueLabel,
                                                                                         qos: .userInitiated))
        let reducerScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: expectedExecuterName, qos: .userInitiated))

        let feedback = RxFeedback(feedback: { (inputs: Observable<Int>) -> Observable<String> in
            return Observable<String>.just("").observeOn(inputStreamScheduler)
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return 0
        }

        // When: reducing with specifying an Executer for the reduce operation
        _ = RxReducer(reducer: reducerFunction, on: reducerScheduler)
            .reduce(initialState: 0, feedback: feedback.feedbackStream)
            .take(2)
            .toBlocking()
            .materialize()

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the feedback
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reduce_outputs_no_error_and_complete_when_feedback_stream_fails() {
        // Given: a feedback that outputs an Error
        var reduceIsCalled = false

        let feedback = RxFeedback(feedback: { (inputs: Observable<Int>) -> Observable<String> in
            return .error(NSError(domain: "feedback", code: 0))
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            return 0
        }

        // When: reducing the feedback loop
        let events = RxReducer(reducer: reducerFunction)
            .reduce(initialState: 0, feedback: feedback.feedbackStream)
            .toBlocking()
            .materialize()

        // Then: the reduce is not performed
        // Then: the feedback loop completes with no error
        XCTAssertFalse(reduceIsCalled)
        XCTAssertEqual(events, MaterializedSequenceResult<Int>.completed(elements: [0]))
    }

    func test_initialState_is_the_first_state_given_to_the_feedbacks() {
        // Given: 2 feedbacks
        let initialState = 1701
        var receivedInitialStateInFeedbackA = 0
        var receivedInitialStateInFeedbackB = 0

        let feedbackA = RxFeedback(feedback: { (input: Int) -> Observable<String> in
            receivedInitialStateInFeedbackA = input
            return .just("")
        })

        let feedbackB = RxFeedback(feedback: { (input: Int) -> Observable<String> in
            receivedInitialStateInFeedbackB = input
            return .just("")
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing the feedbacks
        _ = RxReducer(reducer: reducerFunction)
            .reduce(initialState: initialState, feedback: RxFeedback(feedbacks: feedbackA, feedbackB).feedbackStream)
            .take(1)
            .toBlocking()
            .materialize()

        // Then: the initial states received in the feedbacks are the one specified in the Reducer
        XCTAssertEqual(receivedInitialStateInFeedbackA, initialState)
        XCTAssertEqual(receivedInitialStateInFeedbackB, initialState)
    }

    func test_reduce_with_an_array_of_streams_preserves_the_streams() throws {
        // Given: 2 feedback streams
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false

        let feedbackAFunction = { (inputs: Observable<Int>) -> Observable<String> in
            feedbackAIsCalled = true
            return .just("")
        }
        let feedbackBFunction = { (inputs: Observable<Int>) -> Observable<String> in
            feedbackBIsCalled = true
            return .just("")
        }

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing with those feedback streams
        _ = RxReducer(reducer: reducerFunction)
            .reduce(initialState: 0, feedbacks: [feedbackAFunction, feedbackBFunction])
            .take(2)
            .toBlocking()
            .materialize()

        // Then: the 2 feedbacks are executed
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
    }
}
