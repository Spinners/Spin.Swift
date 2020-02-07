//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift
import XCTest

final class AnySpinTests: XCTestCase {

    func test_initialize_with_several_effects_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: some effects and a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var reducerIsCalled = false

        let effectA = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }
        let effectB = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerOnExecuterFunction = { (state: MockState, events: MockStream<MockEvent>) -> MockStream<MockState> in
            reducerIsCalled = true
            return MockStream<MockState>(value: .toEmpty)
        }

        // When: building an AnySpin based on those feedback stream and reducer
        let sut = AnySpin(initialState: MockState(subState: 0), effects: [effectA, effectB], reducerOnExecuter: reducerOnExecuterFunction)
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(sut.initialState, MockState(subState: 0))
        XCTAssertEqual(sut.effects.count, 2)
        XCTAssertTrue(reducerIsCalled)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_initialize_with_a_feedback_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback and a reducer
        var effectIsCalled = false
        var reducerIsCalled = false

        let effectFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState(subState: 0)
        }

        let feedback = MockFeedback(effect: effectFunction)
        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer
        let sut = AnySpin(initialState: MockState(subState: 0), feedback: feedback, reducer: reducer)
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(sut.initialState, MockState(subState: 0))
        XCTAssertEqual(sut.effects.count, 1)
        XCTAssertTrue(effectIsCalled)
        XCTAssertTrue(reducerIsCalled)
    }

    func test_initialize_with_functionBuilder_with_a_feedback_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback and a reducer
        var effectIsCalled = false
        var reducerIsCalled = false

        let effectFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer, with a declarative syntax
        let sut = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(sut.initialState, MockState(subState: 0))
        XCTAssertEqual(sut.effects.count, 1)
        XCTAssertTrue(effectIsCalled)
        XCTAssertTrue(reducerIsCalled)
    }

    func test_initialize_with_functionBuilder_with_two_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 2 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var reducerIsCalled = false

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(sut.initialState, MockState(subState: 0))
        XCTAssertEqual(sut.effects.count, 2)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(reducerIsCalled)
    }

    func test_initialize_with_functionBuilder_with_three_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 3 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var reducerIsCalled = false

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectCFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectCIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(sut.initialState, MockState(subState: 0))
        XCTAssertEqual(sut.effects.count, 3)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(reducerIsCalled)
    }

    func test_initialize_with_functionBuilder_with_four_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 4 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false
        var reducerIsCalled = false

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectCFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectCIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectDFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectDIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(sut.initialState, MockState(subState: 0))
        XCTAssertEqual(sut.effects.count, 4)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(reducerIsCalled)
    }

    func test_initialize_with_functionBuilder_with_five_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 4 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false
        var effectEIsCalled = false
        var reducerIsCalled = false

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectCFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectCIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectDFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectDIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectEFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectEIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
            MockFeedback(effect: effectEFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(sut.initialState, MockState(subState: 0))
        XCTAssertEqual(sut.effects.count, 5)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(effectEIsCalled)
        XCTAssertTrue(reducerIsCalled)
    }
}
