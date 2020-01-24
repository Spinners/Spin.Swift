//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift
import XCTest

fileprivate class SpyReducer: Reducer {
    let reducer: (MockState, MockEvent) -> MockState
    let executer: MockExecuter

    var reduceIsCalled = false
    var numberOfEffects = 0
    var initialState: MockState?

    required init(reducer: @escaping (MockState, MockEvent) -> MockState, on executer: MockExecuter = MockExecuter()) {
        self.reducer = reducer
        self.executer = executer
    }

    func apply(on initialState: MockState,
               after effects: [(MockStream<MockState>) -> MockStream<MockEvent>]) -> MockStream<MockState> {
        self.initialState = initialState
        self.reduceIsCalled = true
        self.numberOfEffects = effects.count
        effects.forEach { _ = $0(MockStream<MockState>(value: initialState)) }
        _ = self.reducer(initialState, MockEvent(value: 0))
        return MockStream<MockState>(value: MockState(subState: 1701))
    }
}

final class AnySpinTests: XCTestCase {

    func test_initialize_with_several_effects_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: some effects and a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false

        let effectA = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }
        let effectB = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            MockState(subState: 0)
        }

        let reducer = SpyReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback stream and reducer
        _ = AnySpin(initialState: MockState(subState: 0), effects: [effectA, effectB], reducer: reducer)

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(reducer.initialState, MockState(subState: 0))
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 2)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_initialize_with_a_feedback_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback and a reducer
        var effectIsCalled = false
        let effectFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            MockState(subState: 0)
        }

        let feedback = MockFeedback(effect: effectFunction)
        let reducer = SpyReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer
        _ = AnySpin(initialState: MockState(subState: 0), feedback: feedback, reducer: reducer)

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(reducer.initialState, MockState(subState: 0))
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 1)
        XCTAssertTrue(effectIsCalled)
    }

    func test_initialize_with_functionBuilder_with_a_feedback_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback and a reducer
        var effectIsCalled = false
        let effectFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            MockState(subState: 0)
        }

        let reducer = SpyReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(reducer.initialState, MockState(subState: 0))
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 1)
        XCTAssertTrue(effectIsCalled)
    }

    func test_initialize_with_functionBuilder_with_two_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 2 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            MockState(subState: 0)
        }

        let reducer = SpyReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(reducer.initialState, MockState(subState: 0))
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 2)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_initialize_with_functionBuilder_with_three_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 3 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false

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
            MockState(subState: 0)
        }

        let reducer = SpyReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(reducer.initialState, MockState(subState: 0))
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 3)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
    }

    func test_initialize_with_functionBuilder_with_four_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 4 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false

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
            MockState(subState: 0)
        }

        let reducer = SpyReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(reducer.initialState, MockState(subState: 0))
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 4)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
    }

    func test_initialize_with_functionBuilder_with_five_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 4 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false
        var effectEIsCalled = false

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
            MockState(subState: 0)
        }

        let reducer = SpyReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
            MockFeedback(effect: effectEFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertEqual(reducer.initialState, MockState(subState: 0))
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 5)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(effectEIsCalled)
    }
}
