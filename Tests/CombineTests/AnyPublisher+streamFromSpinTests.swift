//
//  AnyPublisher+streamFromSpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import Combine
import SpinCombine
import SpinCommon
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnyPublisher_streamFromSpinTests: XCTestCase {
    private var subscriptions = [AnyCancellable]()

    func test_initialState_is_the_first_state_given_to_the_effects() throws {
        let exp = expectation(description: "Effects")
        // Given: 2 feedbacks and 1 reducer assembled in a Spin with an initialState
        let initialState = "initialState"
        var receivedStatesA = [String]()
        var receivedStatesB = [String]()

        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                receivedStatesA.append(state)
                return "event"
            }.eraseToAnyPublisher()
        })
        let feedbackB = Feedback<String, String>(effect: { states in
            return states.map { state -> String in
                receivedStatesB.append(state)
                return "event"
            }.eraseToAnyPublisher()
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
        AnyPublisher
            .stream(from: spin)
            .output(in: (0...0))
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { _ in })
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 0.5)

        // Then: the feedback's effects receive the initial state
        XCTAssertEqual(receivedStatesA[0], initialState)
        XCTAssertEqual(receivedStatesB[0], initialState)
    }

    func test_initialState_is_the_state_given_to_the_reducer() throws {
        let exp = expectation(description: "Reducer")

        // Given: 1 feedback and 1 reducer assembled in a Spin with an initialState
        let initialState = "initialState"
        var receivedStatesInReducer = [String]()

        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }.eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String>({ state, _ in
            receivedStatesInReducer.append(state)
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState) {
            feedbackA
            reducer
        }

        // When: producing/subscribing to a stream based on the Spin
        AnyPublisher
            .stream(from: spin)
            .output(in: (0...0))
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { _ in })
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 0.5)

        // Then: the reducer receives the initial state
        XCTAssertEqual(receivedStatesInReducer[0], initialState)
    }
}
