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

    func test_apply_is_performed_on_default_executer_when_no_executer_is_specified() {
        // Given: an effect switching on a specified Executer after being executed
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
            .apply(on: 0, after: [feedback.effect])
            .take(first: 2)
            .spin()
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reduce is performed
        // Then: the reduce is performed on the default executer, ie the main queue for ReactiveReducer
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_apply_is_performed_on_dedicated_executer_when_executer_is_specified() {
        // Given: an effect switching on a specified Executer after being executed
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
            .apply(on: 0, after: [feedback.effect])
            .take(first: 2)
            .collect()
            .first()

        // Then: the reduce is performed
        // Then: the reduce is performed on the current executer, ie the one set by the effect
        XCTAssertTrue(reduceIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_initialState_is_the_first_state_given_to_the_feedbacks() {
        // Given: 2 effect
        let initialState = 1701
        var receivedInitialStateInEffectA = 0
        var receivedInitialStateInEffectB = 0

        let effectA = { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            return inputs.map { input in
                receivedInitialStateInEffectA = input
                return "\(input)"
            }
        }

        let effectB = { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            return inputs.map { input in
                receivedInitialStateInEffectB = input
                return "\(input)"
            }
        }

        let reducerFunction = { (state: Int, action: String) -> Int in
            return 0
        }

        // When: reducing the feedbacks
        _ = ReactiveReducer(reducer: reducerFunction)
            .apply(on: initialState, after: [effectA, effectB])
            .take(first: 1)
            .collect()
            .first()

        // Then: the initial states received in the effect are the one specified in the Reducer
        XCTAssertEqual(receivedInitialStateInEffectA, initialState)
        XCTAssertEqual(receivedInitialStateInEffectB, initialState)
    }
}
