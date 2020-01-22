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

    func test_apply_is_performed_on_default_executer_when_no_executer_is_specified() {
        // Given: an effect switching on a specified Executer after being executed
        var reduceIsCalled = false
        let expectedExecuterName = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: expectedExecuterName,
                                                                                         qos: .userInitiated))

        let feedback = RxFeedback(effect: { (inputs: Observable<Int>) -> Observable<String> in
            return Observable<String>.just("").observeOn(inputStreamScheduler)
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return 0
        }

        // When: reducing without specifying an Executer for the reduce operation
        _ = RxReducer(reducer: reducerFunction)
            .apply(on: 0, after: [feedback.effect])
            .take(2)
            .toBlocking()
            .materialize()

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for RxReducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_apply_is_performed_on_dedicated_executer_when_executer_is_specified() {
        // Given: an effect switching on a specified Executer after being executed
        var reduceIsCalled = false
        let expectedExecuterName = "REDUCER_QUEUE_\(UUID().uuidString)"
        var receivedExecuterName = ""

        let inputStreamSchedulerQueueLabel = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: inputStreamSchedulerQueueLabel,
                                                                                         qos: .userInitiated))
        let reducerScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: expectedExecuterName, qos: .userInitiated))

        let feedback = RxFeedback(effect: { (inputs: Observable<Int>) -> Observable<String> in
            return Observable<String>.just("").observeOn(inputStreamScheduler)
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            receivedExecuterName = DispatchQueue.currentLabel
            return 0
        }

        // When: reducing with specifying an Executer for the reduce operation
        _ = RxReducer(reducer: reducerFunction, on: reducerScheduler)
            .apply(on: 0, after: [feedback.effect])
            .take(2)
            .toBlocking()
            .materialize()

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the feedback
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_reduce_outputs_no_error_and_complete_when_feedback_stream_fails() {
        // Given: an effect that outputs an Error
        var reduceIsCalled = false

        let feedback = RxFeedback(effect: { (inputs: Observable<Int>) -> Observable<String> in
            return .error(NSError(domain: "feedback", code: 0))
        })

        let reducerFunction = { (state: Int, action: String) -> Int in
            reduceIsCalled = true
            return 0
        }

        // When: reducing the feedback loop
        let events = RxReducer(reducer: reducerFunction)
            .apply(on: 0, after: [feedback.effect])
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
        var receivedInitialStateInEffectA = 0
        var receivedInitialStateInEffectB = 0

        let effectA = { (inputs: Observable<Int>) -> Observable<String> in
            return inputs.map { input in
                receivedInitialStateInEffectA = input
                return "\(input)"
            }
        }

        let effectB = { (inputs: Observable<Int>) -> Observable<String> in
            return inputs.map { input in
                receivedInitialStateInEffectB = input
                return "\(input)"
            }
        }

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing the feedbacks
        _ = RxReducer(reducer: reducerFunction)
            .apply(on: initialState, after: [effectA, effectB])
            .take(1)
            .toBlocking()
            .materialize()

        // Then: the initial states received in the effects are the one specified in the Reducer
        XCTAssertEqual(receivedInitialStateInEffectA, initialState)
        XCTAssertEqual(receivedInitialStateInEffectB, initialState)
    }
}
