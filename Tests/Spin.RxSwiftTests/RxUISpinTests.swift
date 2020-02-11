//
//  RxUISpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-07.
//

import Combine
import RxSwift
import Spin_RxSwift
import XCTest

fileprivate class SpyContainer {

    var isRenderCalled = false
    var receivedState = ""

    func render(state: String) {
        self.receivedState = state
        self.isRenderCalled = true
    }
}

final class RxUISpinTests: XCTestCase {

    private let disposeBag = DisposeBag()

    func test_RxUISpin_sets_the_published_state_with_the_initialState_of_the_inner_spin() {
        // Given: a Spin with an initialState
        let initialState = "initialState"

        let feedback = RxFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = RxReducer<String, String>(reducer: { state, _ in
            return "newState"
        })

        let spin = RxSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a RxUISpin with the Spin
        let sut = RxUISpin(spin: spin)

        // Then: the RxUISpin sets the published state with the initialState
        XCTAssertEqual(sut.state, initialState)
    }

    func test_RxUISpin_initialization_adds_a_ui_effect_to_the_inner_spin() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = RxFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = RxReducer<String, String>(reducer: { state, _ in
            return "newState"
        })

        let spin = RxSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a RxUISpin with the Spin
        let sut = RxUISpin(spin: spin)

        // Then: the RxUISpin adds 1 new ui effect
        XCTAssertEqual(sut.effects.count, 2)
    }

    func test_RxUISpin_render_calls_the_external_function_with_initialState() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = RxFeedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = RxReducer<String, String>(reducer: { state, _ in
            return "newState"
        })

        let spin = RxSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        let container = SpyContainer()

        // When: building a RxUISpin with the Spin and setting an external render function
        let sut = RxUISpin(spin: spin)
        sut.render(on: container, using: { $0.render(state:) })

        // Then: the external render function is called with the initialState of the Spin
        XCTAssertTrue(container.isRenderCalled)
        XCTAssertEqual(container.receivedState, "initialState")
    }

    func test_RxUISpin_send_events_in_the_reducer_when_emit_is_called() {
        // Given: a Spin
        let exp = expectation(description: "emit")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = RxFeedback<String, String>(effect: { states in
            return .empty()
        })

        let reducer = RxReducer<String, String>(reducer: { state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = RxSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a RxUISpin with the Spin and running the RxUISpin and emitting an event
        let sut = RxUISpin(spin: spin)
        sut.toReactiveStream().take(2).subscribe().disposed(by: self.disposeBag)
        sut.emit("newEvent")

        waitForExpectations(timeout: 5)

        // Then: the event is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_binding_make_the_RxUISpin_emit_an_event_when_the_binding_is_mutated() {
        // Given: a Spin
        let exp = expectation(description: "binding")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = RxFeedback<String, String>(effect: { states in
            return .empty()
        })

        let reducer = RxReducer<String, String>(reducer: { state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = RxSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a RxUISpin with the Spin and running the RxUISpin and getting a binding
        // and then mutating the wrapped value of the binding
        let sut = RxUISpin(spin: spin)
        sut.toReactiveStream().take(2).subscribe().disposed(by: self.disposeBag)
        let binding = sut.binding(for: \.count, event: { "\($0)" })
        binding.wrappedValue = 16

        waitForExpectations(timeout: 5)

        // Then: the event from the binding mutation is received in the reducer
        XCTAssertEqual(receivedEvent, "16")
    }

    func test_binding_make_the_RxUISpin_emit_directly_an_event_when_the_binding_is_mutated() {
        // Given: a Spin
        let exp = expectation(description: "binding")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = RxFeedback<String, String>(effect: { states in
            return .empty()
        })

        let reducer = RxReducer<String, String>(reducer: { state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = RxSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a RxUISpin with the Spin and running the RxUISpin and getting a binding
        // and then mutating the wrapped value of the binding
        let sut = RxUISpin(spin: spin)
        sut.toReactiveStream().take(2).subscribe().disposed(by: self.disposeBag)
        let binding = sut.binding(for: \.count, event: "newEvent")
        binding.wrappedValue = 16

        waitForExpectations(timeout: 5)

        // Then: the event from the binding mutation is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_RxUISpin_runs_the_stream_when_spin_is_called() {
        // Given: a Spin
        let exp = expectation(description: "spin")
        let initialState = "initialState"
        var receivedState = ""

        let feedback = RxFeedback<String, String>(effect: { (state: String) in
            receivedState = state
            exp.fulfill()
            return .empty()
        })

        let reducer = RxReducer<String, String>(reducer: { state, event in
            return "newState"
        })

        let spin = RxSpin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a RxUISpin with the Spin and running the RxUISpin
        let sut = RxUISpin(spin: spin)
        sut.spin()

        waitForExpectations(timeout: 5)

        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }
}
