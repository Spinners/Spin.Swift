//
//  CombineUISpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import Combine
import Spin_Combine
import XCTest

fileprivate class SpyContainer {

    var isRenderCalled = false
    var receivedState = ""

    func render(state: String) {
        self.receivedState = state
        self.isRenderCalled = true
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineUISpinTests: XCTestCase {

    private var disposeBag = [AnyCancellable]()

    func test_CombineUISpin_sets_the_initial_state_with_the_initialState_of_the_inner_spin() {
        // Given: a Spin with an initialState
        let initialState = "initialState"

        let feedback = CombineFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }.eraseToAnyPublisher()
        })

        let reducer = CombineReducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = CombineSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a CombineUISpin with the Spin
        let sut = CombineUISpin(spin: spin)

        // Then: the CombineUISpin sets the initial state with the initialState from the inner Spin
        XCTAssertEqual(sut.initialState, initialState)
    }

    func test_CombineUISpin_initialization_adds_a_ui_effect_to_the_inner_spin() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = CombineFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }.eraseToAnyPublisher()
        })

        let reducer = CombineReducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = CombineSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a CombineUISpin with the Spin
        let sut = CombineUISpin(spin: spin)

        // Then: the CombineUISpin adds 1 new ui effect
        XCTAssertEqual(sut.effects.count, 2)
    }

    func test_CombineUISpin_send_events_in_the_reducer_when_emit_is_called() throws {
        // Given: a Spin
        let exp = expectation(description: "emit")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = CombineFeedback<String, String>(effect: { states in
            return Empty().eraseToAnyPublisher()
        })

        let reducer = CombineReducer<String, String>({ state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = CombineSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a CombineUISpin with the Spin and running the CombineUISpin and emitting an event
        let sut = CombineUISpin(spin: spin)
        sut.toReactiveStream().output(in: (0...1)).eraseToAnyPublisher().spin().store(in: &self.disposeBag)
        sut.emit("newEvent")

        waitForExpectations(timeout: 5)

        // Then: the event is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_CombineUISpin_runs_the_stream_when_start_is_called() {
        // Given: a Spin
        let exp = expectation(description: "spin")
        let initialState = "initialState"
        var receivedState = ""

        let feedback = CombineFeedback<String, String>(effect: { (state: String) in
            receivedState = state
            exp.fulfill()
            return Empty().eraseToAnyPublisher()
        })

        let reducer = CombineReducer<String, String>({ state, event in
            return "newState"
        })

        let spin = CombineSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a CombineUISpin with the Spin and running the CombineUISpin
        let sut = CombineUISpin(spin: spin)
        sut.start()

        waitForExpectations(timeout: 5)

        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }
}
