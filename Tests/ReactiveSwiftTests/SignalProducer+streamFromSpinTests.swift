//
//  SignalProducer+streamFromSpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import ReactiveSwift
import SpinCommon
import SpinReactiveSwift
import XCTest

final class SignalProducer_streamFromSpinTests: XCTestCase {
    private let disposables = CompositeDisposable()
        
    func test_initialState_is_the_first_state_given_to_the_effects() {
        // Given: 2 feedbacks and 1 reducer assembled in a Spin with an initialState
        let exp = expectation(description: "initialState")
        let initialState = "initialState"
        var receivedStatesA = [String]()
        var receivedStatesB = [String]()
        
        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                receivedStatesA.append(state)
                return "event"
            }
        })
        let feedbackB = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                receivedStatesB.append(state)
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
            .take(first: 2)
            .startWithCompleted { exp.fulfill() }
            .add(to: self.disposables)

        waitForExpectations(timeout: 0.5)
        
        // Then: the feedback's effects receive the initial state
        XCTAssertEqual(receivedStatesA[0], initialState)
        XCTAssertEqual(receivedStatesB[0], initialState)
    }
    
    func test_initialState_is_the_state_given_to_the_reducer() {
        let exp = expectation(description: "Reducer")
        
        // Given: 1 feedback and 1 reducer assembled in a Spin with an initialState
        let initialState = "initialState"
        var receivedStatesInReducer = [String]()
        
        let feedbackA = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                print("FEEDBACK state=\(state)")
                return "event"
            }
        })
        
        let reducer = Reducer<String, String>({ state, _ in
            print("REDUCER state=\(state)")
            receivedStatesInReducer.append(state)
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
            .startWithCompleted { exp.fulfill() }
            .add(to: self.disposables)

        waitForExpectations(timeout: 0.5)
        
        // Then: the reducer receives the initial state
        XCTAssertEqual(receivedStatesInReducer[0], initialState)
    }
}
