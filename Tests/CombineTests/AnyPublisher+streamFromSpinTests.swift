//
//  AnyPublisher+streamFromSpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import Combine
import SpinCombine
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnyPublisher_streamFromSpinTests: XCTestCase {

    func test_initialState_is_the_first_state_given_to_the_effects() throws {
        // Given: 2 feedbacks and 1 reducer assembled in a Spin with an initialState
        let initialState = "initialState"
        var receivedInitialStateInEffectA = ""
        var receivedInitialStateInEffectB = ""

        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                receivedInitialStateInEffectA = state
                return "event"
            }.eraseToAnyPublisher()
        })
        let feedbackB = Feedback<String, String>(effect: { states in
            return states.map { state -> String in
                receivedInitialStateInEffectB = state
                return "event"
            }.eraseToAnyPublisher()
        })
        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedbackA
            feedbackB
        }

        // When: producing/subscribing to a stream based on the Spin
        let recorder = AnyPublisher
            .stream(from: spin)
            .output(in: (0..<1))
            .record()

        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the feedback's effects receive the initial state
        XCTAssertEqual(receivedInitialStateInEffectA, initialState)
        XCTAssertEqual(receivedInitialStateInEffectB, initialState)
    }

    func test_initialState_is_the_state_given_to_the_reducer() throws {
        // Given: 1 feedback and 1 reducer assembled in a Spin with an initialState
        let initialState = "initialState"
        var receivedInitialStateInReducer = ""

        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }.eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String>({ state, _ in
            receivedInitialStateInReducer = state
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedbackA
        }

        // When: producing/subscribing to a stream based on the Spin
        let recorder = AnyPublisher
            .stream(from: spin)
            .output(in: (0...1))
            .record()

        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the reducer receives the initial state
        XCTAssertEqual(receivedInitialStateInReducer, initialState)
    }
}
