//
//  SignalProducer+streamFromSpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import ReactiveSwift
import SpinReactiveSwift
import XCTest

final class SignalProducer_streamFromSpinTests: XCTestCase {

    private let disposeBag = CompositeDisposable()

    func test_initialState_is_the_first_state_given_to_the_effects() {
        // Given: 2 feedbacks and 1 reducer assembled in a Spin with an initialState
        let exp = expectation(description: "initialState")
        let initialState = "initialState"
        var receivedInitialStateInEffectA = ""
        var receivedInitialStateInEffectB = ""

        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                receivedInitialStateInEffectA = state
                return "event"
            }
        })
        let feedbackB = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                receivedInitialStateInEffectB = state
                exp.fulfill()
                return "event"
            }
        })
        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState) {
            feedbackA
            feedbackB
            reducer
        }

        // When: producing/subscribing to a stream based on the Spin
        _ = SignalProducer
            .stream(from: spin)
            .take(first: 1)
            .start()
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the feedback's effects receive the initial state
        XCTAssertEqual(receivedInitialStateInEffectA, initialState)
        XCTAssertEqual(receivedInitialStateInEffectB, initialState)
    }

    func test_initialState_is_the_state_given_to_the_reducer() {
        // Given: 1 feedback and 1 reducer assembled in a Spin with an initialState
        let exp = expectation(description: "initialState")
        let initialState = "initialState"
        var receivedInitialStateInReducer = ""

        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = Reducer<String, String>({ state, _ in
            receivedInitialStateInReducer = state
            exp.fulfill()
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState) {
            feedbackA
            reducer
        }

        // When: producing/subscribing to a stream based on the ReactiveSpin
        _ = SignalProducer
            .stream(from: spin)
            .take(first: 2)
            .start()
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reducer receives the initial state
        XCTAssertEqual(receivedInitialStateInReducer, initialState)
    }
}
