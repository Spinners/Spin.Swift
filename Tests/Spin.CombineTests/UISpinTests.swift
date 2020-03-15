//
//  UISpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import Combine
import Spin_Combine
import XCTest

fileprivate class SpyRenderer {

    var isRenderCalled = false
    var receivedState = ""

    func render(state: String) {
        self.receivedState = state
        self.isRenderCalled = true
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class UISpinTests: XCTestCase {

    private var disposeBag = [AnyCancellable]()

    func test_UISpin_sets_the_initial_state_with_the_initialState_of_the_inner_spin() {
        // Given: a Spin with an initialState
        let initialState = "initialState"

        let feedback = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }.eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a UISpin with the Spin
        let sut = UISpin(spin: spin)

        // Then: the UISpin sets the initial state with the initialState from the inner Spin
        XCTAssertEqual(sut.initialState, initialState)
    }

    func test_UISpin_initialization_adds_a_ui_effect_to_the_inner_spin() {
        // Given: a Spin with an initialState and 1 effect
        let initialState = "initialState"

        let feedback = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }.eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a UISpin with the Spin
        let sut = UISpin(spin: spin)

        // Then: the UISpin adds 1 new ui effect
        XCTAssertEqual(sut.effects.count, 2)
    }

    func test_UISpin_send_events_in_the_reducer_when_emit_is_called() throws {
        // Given: a Spin
        let exp = expectation(description: "emit")
        let initialState = "initialState"
        var receivedEvent = ""

        let feedback = Feedback<String, String>(effect: { states in
            return Empty().eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String>({ state, event in
            receivedEvent = event
            exp.fulfill()
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a UISpin with the Spin and running the UISpin and emitting an event
        let sut = UISpin(spin: spin)
        AnyPublisher
            .stream(from: sut)
            .output(in: (0...1))
            .subscribe()
            .disposed(by: &self.disposeBag)

        sut.emit("newEvent")

        waitForExpectations(timeout: 5)

        // Then: the event is received in the reducer
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_UISpin_runs_the_stream_when_start_is_called() {
        // Given: a Spin
        let exp = expectation(description: "spin")
        let initialState = "initialState"
        var receivedState = ""

        let feedback = Feedback<String, String>(effect: { (state: String) in
            receivedState = state
            exp.fulfill()
            return Empty().eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String>({ state, event in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a UISpin with the Spin and running the UISpin
        let sut = UISpin(spin: spin)
        AnyPublisher
            .start(spin: sut)
            .disposed(by: &self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }

    func test_UISpin_runs_the_external_render_function () throws {
        // Given: a Spin with an initialState and 1 effect
        // Given: a SpyRenderer that will render the state mutations
        let spyRenderer = SpyRenderer()

        let initialState = "initialState"

        let feedback = Feedback<String, String>(effect: { states in
            states.map { state -> String in
                return "event"
            }.eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })

        let spin = Spin<String, String>(initialState: initialState, reducer: reducer) {
            feedback
        }

        // When: building a UISpin with the Spin and attaching the spyRenderer as the renderer of the uiSpin
        // When: starting the spin
        let sut = UISpin(spin: spin)
        sut.render(on: spyRenderer, using: { $0.render(state:) })

        let recorder = AnyPublisher
            .stream(from: sut)
            .output(in: (0...2))
            .record()

        _ = try wait(for: recorder.completion, timeout: 5)

        // Then: the spyRenderer is called
        XCTAssertTrue(spyRenderer.isRenderCalled)
        XCTAssertEqual(spyRenderer.receivedState, "newState")
    }
}
