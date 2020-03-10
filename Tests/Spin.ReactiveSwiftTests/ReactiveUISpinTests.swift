//
//  ReactiveUISpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import Combine
import ReactiveSwift
import Spin_ReactiveSwift
import Spin_Swift
import XCTest

fileprivate class SpyRenderer {

    var isRenderCalled = false
    var receivedState = ""

    func render(state: String) {
        self.receivedState = state
        self.isRenderCalled = true
    }
}

final class ReactiveUISpinTests: XCTestCase {

    private let disposeBag = CompositeDisposable()

    func test_ReactiveUISpin_sets_the_initial_state_with_the_initialState_of_the_inner_spin() {
        // Given: a Spin with an initialState
        let initialState = "initialState"

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = ReactiveReducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin
        let sut = ReactiveUISpin(spin: spin)

        // Then: the ReactiveUISpin sets the initial state with the initialState of the inner Spin
        XCTAssertEqual(sut.initialState, initialState)
    }

    func test_ReactiveUISpin_initialization_adds_a_ui_effect_to_the_inner_spin() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = ReactiveReducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin
        let sut = ReactiveUISpin(spin: spin)

        // Then: the ReactiveUISpin adds 1 new ui effect
        XCTAssertEqual(sut.effects.count, 2)
    }

    func test_ReactiveUISpin_send_events_in_the_reducer_when_emit_is_called() {
        // Given: a Spin
        let exp = expectation(description: "emit")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            return .empty
        })

        let reducer = ReactiveReducer<String, String>({ state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin and running the ReactiveUISpin and emitting an event
        let sut = ReactiveUISpin(spin: spin)
        SignalProducer
            .stream(from: sut)
            .take(first: 2)
            .start()
            .disposed(by: self.disposeBag)

        sut.emit("newEvent")

        waitForExpectations(timeout: 5)

        // Then: the event is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_ReactiveUISpin_runs_the_stream_when_start_is_called() {
        // Given: a Spin
        let exp = expectation(description: "spin")
        let initialState = "initialState"
        var receivedState = ""

        let feedback = ReactiveFeedback<String, String>(effect: { (state: String) in
            receivedState = state
            exp.fulfill()
            return .empty
        })

        let reducer = ReactiveReducer<String, String>({ state, event in
            return "newState"
        })

        let spin = Spinner
            .initialState(initialState)
            .feedback(feedback)
            .reducer(reducer)

        // When: building a ReactiveUISpin with the Spin and running the ReactiveUISpin
        let sut = ReactiveUISpin(spin: spin)
        SignalProducer
            .start(spin: sut)
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }

    func test_ReactiveUISpin_runs_the_external_render_function() {
        // Given: a Spin with an initialState and 1 effect
        // Given: a SpyRenderer that will render the state mutations
        let exp = expectation(description: "spin")
        let spyRenderer = SpyRenderer()

        let initialState = "initialState"

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            states.map { state -> String in
                if state == "newState" {
                    exp.fulfill()
                }
                return "event"
            }
        })

        let reducer = ReactiveReducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin and attaching the spyRenderer as the renderer of the uiSpin
        // When: starting the spin
        let sut = ReactiveUISpin(spin: spin)
        sut.render(on: spyRenderer, using: { $0.render(state:) })

        SignalProducer
            .stream(from: sut)
            .take(first: 2)
            .start()
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the spyRenderer is called
        XCTAssertTrue(spyRenderer.isRenderCalled)
        XCTAssertEqual(spyRenderer.receivedState, "newState")
    }
}
