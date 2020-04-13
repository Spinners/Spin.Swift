//
//  SwiftUISpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import Combine
import RxSwift
import SpinRxSwift
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SwiftUISpinTests: XCTestCase {

    private let disposeBag = DisposeBag()

    func test_SwiftUISpin_sets_the_published_state_with_the_initialState_of_the_inner_spin() {
        // Given: a Spin with an initialState
        let initialState = "initialState"

        let feedback = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a SwiftUISpin with the Spin
        let sut = SwiftUISpin(spin: spin)

        // Then: the UISpin sets the published state with the initialState
        XCTAssertEqual(sut.state, initialState)
    }

    func test_SwiftUISpin_initialization_adds_a_ui_effect_to_the_inner_spin() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }
        })

        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a SwiftUISpin with the Spin
        let sut = SwiftUISpin(spin: spin)

        // Then: the UISpin adds 1 new ui effect
        XCTAssertEqual(sut.effects.count, 2)
    }

    func test_SwiftUISpin_send_events_in_the_reducer_when_emit_is_called() {
        // Given: a Spin
        let exp = expectation(description: "emit")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = Feedback<String, String>(effect: { states in
            return .empty()
        })

        let reducer = Reducer<String, String>({ state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin and emitting an event
        let sut = SwiftUISpin(spin: spin)
        Observable
            .stream(from: sut)
            .take(2)
            .subscribe()
            .disposed(by: self.disposeBag)

        sut.emit("newEvent")

        waitForExpectations(timeout: 5)

        // Then: the event is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_binding_make_the_SwiftUISpin_emit_an_event_when_the_binding_is_mutated() {
        // Given: a Spin
        let exp = expectation(description: "binding")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = Feedback<String, String>(effect: { states in
            return .empty()
        })

        let reducer = Reducer<String, String>({ state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin and getting a binding
        // and then mutating the wrapped value of the binding
        let sut = SwiftUISpin(spin: spin)
        Observable
            .stream(from: sut)
            .take(2)
            .subscribe()
            .disposed(by: self.disposeBag)

        let binding = sut.binding(for: \.count, event: { "\($0)" })
        binding.wrappedValue = 16

        waitForExpectations(timeout: 5)

        // Then: the event from the binding mutation is received in the reducer
        XCTAssertEqual(receivedEvent, "16")
    }

    func test_binding_make_the_SwiftUISpin_emit_directly_an_event_when_the_binding_is_mutated() {
        // Given: a Spin
        let exp = expectation(description: "binding")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = Feedback<String, String>(effect: { states in
            return .empty()
        })

        let reducer = Reducer<String, String>({ state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin and getting a binding
        // and then mutating the wrapped value of the binding
        let sut = SwiftUISpin(spin: spin)
        Observable
            .stream(from: sut)
            .take(2)
            .subscribe()
            .disposed(by: self.disposeBag)

        let binding = sut.binding(for: \.count, event: "newEvent")
        binding.wrappedValue = 16

        waitForExpectations(timeout: 5)

        // Then: the event from the binding mutation is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_SwiftUISpin_runs_the_stream_when_start_is_called() {
        // Given: a Spin
        let exp = expectation(description: "spin")
        let initialState = "initialState"
        var receivedState = ""

        let feedback = Feedback<String, String>(effect: { (state: String) in
            receivedState = state
            exp.fulfill()
            return .empty()
        })

        let reducer = Reducer<String, String>({ state, event in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin
        let sut = SwiftUISpin(spin: spin)
        Observable
            .start(spin: sut)
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }

    func test_SwiftUISpin_mutates_the_inner_state() {
        // Given: a Spin with an initialState and 1 effect
        let exp = expectation(description: "spin")

        let initialState = "initialState"

        let feedback = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                if state == "newState" {
                    exp.fulfill()
                }
                return "event"
            }
        })

        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a UISpin with the Spin
        // When: starting the spin
        let sut = UISpin(spin: spin)

        Observable
            .stream(from: sut)
            .take(2)
            .subscribe()
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the state is mutated
        XCTAssertEqual(sut.state, "newState")
    }
}
