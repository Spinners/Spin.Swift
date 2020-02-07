//
//  ReactiveUISpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import Combine
import ReactiveSwift
import Spin_ReactiveSwift
import XCTest

fileprivate class SpyContainer {

    var isRenderCalled = false
    var receivedState = ""

    func render(state: String) {
        self.receivedState = state
        self.isRenderCalled = true
    }
}

final class ReactiveUISpinTests: XCTestCase {

    private let disposeBag = CompositeDisposable()

    func test_ReactiveUISpin_sets_the_published_state_with_the_initialState_of_the_inner_spin() {
        // Given: a Spin with an initialState
        let initialState = "initialState"

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = ReactiveReducer<String, String>(reducer: { state, _ in
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin
        let sut = ReactiveUISpin(spin: spin)

        // Then: the ReactiveUISpin sets the published state with the initialState
        XCTAssertEqual(sut.state, initialState)
    }

    func test_ReactiveUISpin_initialization_adds_a_ui_effect_to_the_inner_spin() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = ReactiveReducer<String, String>(reducer: { state, _ in
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

    func test_ReactiveUISpin_render_calls_the_external_function_with_initialState() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = ReactiveReducer<String, String>(reducer: { state, _ in
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        let container = SpyContainer()

        // When: building a ReactiveUISpin with the Spin and setting an external render function
        let sut = ReactiveUISpin(spin: spin)
        sut.render(on: container, using: { $0.render(state:) })

        // Then: the external render function is called with the initialState of the Spin
        XCTAssertTrue(container.isRenderCalled)
        XCTAssertEqual(container.receivedState, "initialState")
    }

    func test_ReactiveUISpin_send_events_in_the_reducer_when_emit_is_called() {
        // Given: a Spin
        let exp = expectation(description: "emit")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            return .empty
        })

        let reducer = ReactiveReducer<String, String>(reducer: { state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin and running the ReactiveUISpin and emitting an event
        let sut = ReactiveUISpin(spin: spin)
        sut.toReactiveStream().take(first: 2).start().disposed(by: self.disposeBag)
        sut.emit("newEvent")

        waitForExpectations(timeout: 5)

        // Then: the event is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_binding_make_the_ReactiveUISpin_emit_an_event_when_the_binding_is_mutated() {
        // Given: a Spin
        let exp = expectation(description: "binding")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = ReactiveFeedback<String, String>(effect: { states in
            return .empty
        })

        let reducer = ReactiveReducer<String, String>(reducer: { state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin and running the ReactiveUISpin and getting a binding
        // and then mutating the wrapped value of the binding
        let sut = ReactiveUISpin(spin: spin)
        sut.toReactiveStream().take(first: 2).start().disposed(by: self.disposeBag)
        let binding = sut.binding(for: \.count, event: { "\($0)" })
        binding.wrappedValue = 16

        waitForExpectations(timeout: 5)

        // Then: the event from the binding mutation is received in the reducer
        XCTAssertEqual(receivedEvent, "16")
    }

    func test_ReactiveUISpin_runs_the_stream_when_spin_is_called() {
        // Given: a Spin
        let exp = expectation(description: "spin")
        let initialState = "initialState"
        var receivedState = ""

        let feedback = ReactiveFeedback<String, String>(effect: { (state: String) in
            receivedState = state
            exp.fulfill()
            return .empty
        })

        let reducer = ReactiveReducer<String, String>(reducer: { state, event in
            return "newState"
        })

        let spin = ReactiveSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a ReactiveUISpin with the Spin and running the ReactiveUISpin
        let sut = ReactiveUISpin(spin: spin)
        sut.spin()

        waitForExpectations(timeout: 5)

        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }
}
