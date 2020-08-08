//
//  UISpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-09.
//

import Combine
@testable import SpinCombine
import SpinCommon
import XCTest

fileprivate class SpyRenderer {
    var receivedState = ""
    var executionQueue = ""
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func render(state: String) {
        self.executionQueue = DispatchQueue.currentLabel
        self.receivedState = state
        self.expectation.fulfill()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class UISpinTests: XCTestCase {
    private var subscriptions = [AnyCancellable]()

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

        let spin = Spin<String, String>(initialState: initialState) {
            feedback
            reducer
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

        let spin = Spin<String, String>(initialState: initialState) {
            feedback
            reducer
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

        let spin = Spin<String, String>(initialState: initialState) {
            feedback
            reducer
        }

        // When: building a UISpin with the Spin and running the UISpin and emitting an event
        let sut = UISpin(spin: spin)

        AnyPublisher
            .stream(from: sut)
            .subscribe()
            .store(in: &self.subscriptions)

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

        let spin = Spin<String, String>(initialState: initialState) {
            feedback
            reducer
        }

        // When: building a UISpin with the Spin and running the UISpin
        let sut = UISpin(spin: spin)
        AnyPublisher
            .start(spin: sut)
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 5)

        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }

    func test_UISpin_runs_the_external_render_function () throws {
        let exp = expectation(description: "Render")
        // we are awaiting 2 expectations (one for each rendered state initialState/newState)
        exp.expectedFulfillmentCount = 2

        // Given: a Spin with an initialState and 1 effect
        // Given: a SpyRenderer that will render the state mutations
        let expectedState = "newState"
        let expectedExecutionQueue = "com.apple.main-thread"
        let spyRenderer = SpyRenderer(expectation: exp)

        let initialState = "initialState"

        let feedback = Feedback<String, String>(effect: { (state: String) -> AnyPublisher<String, Never> in
            guard state == "initialState" else { return Empty().eraseToAnyPublisher() }
            return Just<String>("event").eraseToAnyPublisher()
        })

        let reducer = Reducer<String, String> { state, _ in
            return "newState"
        }

        let spin = Spin<String, String>(initialState: initialState) {
            feedback
            reducer
        }

        // When: building a UISpin with the Spin and attaching the spyRenderer as the renderer of the uiSpin
        // When: starting the spin
        let sut = UISpin(spin: spin)
        sut.render(on: spyRenderer, using: { $0.render(state:) })

        AnyPublisher
            .stream(from: sut)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 0.5)

        // Then: the spyRenderer is called on the main thread
        XCTAssertEqual(spyRenderer.executionQueue, expectedExecutionQueue)
        XCTAssertEqual(spyRenderer.receivedState, expectedState)
    }
}
