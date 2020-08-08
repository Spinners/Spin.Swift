//
//  SwiftUISpinTests.swift
//
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import Combine
import SpinCombine
import SpinCommon
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SwiftUISpinTests: XCTestCase {
    private var subscriptions = [AnyCancellable]()
    
    func test_SwiftUISpin_sets_the_published_state_with_the_initialState_of_the_inner_spin() {
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
        
        // When: building a SwiftUISpin with the Spin
        let sut = SwiftUISpin(spin: spin)
        
        // Then: the SwiftUISpin sets the published state with the initialState
        XCTAssertEqual(sut.state, initialState)
    }
    
    func test_SwiftUISpin_initialization_adds_a_ui_effect_to_the_inner_spin() {
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
        
        // When: building a SwiftUISpin with the Spin
        let sut = SwiftUISpin(spin: spin)
        
        // Then: the SwiftUISpin adds 1 new ui effect
        XCTAssertEqual(sut.effects.count, 2)
    }
    
    func test_SwiftUISpin_send_events_in_the_reducer_when_emit_is_called() throws {
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
        
        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin and emitting an event
        let sut = SwiftUISpin(spin: spin)
        AnyPublisher
            .stream(from: sut)
            .output(in: (0...0))
            .subscribe()
            .store(in: &self.subscriptions)

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
        
        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin and getting a binding
        // and then mutating the wrapped value of the binding
        let sut = SwiftUISpin(spin: spin)
        AnyPublisher
            .stream(from: sut)
            .output(in: (0...0))
            .subscribe()
            .store(in: &self.subscriptions)

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
        
        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin and getting a binding
        // and then mutating the wrapped value of the binding
        let sut = SwiftUISpin(spin: spin)
        AnyPublisher
            .stream(from: sut)
            .output(in: (0...0))
            .subscribe()
            .store(in: &self.subscriptions)

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
            return Empty().eraseToAnyPublisher()
        })
        
        let reducer = Reducer<String, String>({ state, event in
            return "newState"
        })
        
        let spin = Spin<String, String>(initialState: initialState) {
            feedback
            reducer
        }
        
        // When: building a SwiftUISpin with the Spin and running the SwiftUISpin
        let sut = SwiftUISpin(spin: spin)
        AnyPublisher
            .start(spin: sut)
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 5)
        
        // Then: the reactive stream is launched and the initialState is received in the effect
        XCTAssertEqual(receivedState, initialState)
    }

    func test_SwiftUISpin_mutates_the_inner_state() throws {
        let exp = expectation(description: "SwiftUISpin")
        // we are expecting 2 fulfillment since the ui state will receive initialState and then newState
        exp.expectedFulfillmentCount = 2

        // Given: a Spin with an initialState and 1 effect
        let expectedExecutionQueue = "com.apple.main-thread"
        var receivedExecutionQueue = ""
        let expectedState = "newState"
        let initialState = "initialState"
        
        let feedback = Feedback<String, String>(effect: { (state: String) -> AnyPublisher<String, Never> in
            guard state == "initialState" else { return Empty().eraseToAnyPublisher() }
            return Just<String>("event").eraseToAnyPublisher()
        })
        
        let reducer = Reducer<String, String>({ state, _ in
            return "newState"
        })
        
        let spin = Spin<String, String>(initialState: initialState) {
            feedback
            reducer
        }
        
        // When: building a SwiftUISpin with the Spin
        // When: starting the spin
        let sut = SwiftUISpin(spin: spin, extraRenderStateFunction: {
            receivedExecutionQueue = DispatchQueue.currentLabel
        })
        
        AnyPublisher
            .stream(from: sut)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &self.subscriptions)

        sut.$state.sink { _ in
            exp.fulfill()
        }.store(in: &self.subscriptions)
        
        waitForExpectations(timeout: 0.5)
        
        // Then: the state is mutated on the main thread
        XCTAssertEqual(sut.state, expectedState)
        XCTAssertEqual(receivedExecutionQueue, expectedExecutionQueue)
    }
}
