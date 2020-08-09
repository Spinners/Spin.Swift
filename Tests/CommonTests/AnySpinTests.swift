//
//  AnySpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import SpinCommon
import XCTest

final class AnySpinTests: XCTestCase {

    func test_initialize_without_executer_uses_default_executer() {
        // Given: a Spin instantiated without an Executer
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: .init(subState: 0),
                                                                                      effects: [],
                                                                                      reducer: { _, _ in .toEmpty})

        // When: getting the used Executer
        // Then: this is the default one
        XCTAssertEqual(sut.executer, MockExecuter.defaultSpinExecuter())
    }

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

        let reducer = { (state: MockState, evernt: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState.toEmpty
        }

        // When: building an AnySpin based on those feedback stream and reducer
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: MockState(subState: 0),
                                                                                      effects: [effectA, effectB],
                                                                                      reducer: reducer,
                                                                                      executer: MockExecuter())
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducer(MockState.toEmpty, MockEvent.toEmpty)

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

        let spyFeedback = MockFeedback(effect: effectFunction)
        let spyReducer = Reducer<MockState, MockEvent> { _, _ in
            reducerIsCalled = true
            return MockState.toEmpty
        }

        // When: building an AnySpin based on those feedback and reducer
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: MockState(subState: 0),
                                                                                      feedback: spyFeedback,
                                                                                      reducer: spyReducer,
                                                                                      executeOn: MockExecuter())
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducer(MockState.toEmpty, MockEvent.toEmpty)

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

        // When: building an AnySpin based on those feedback and reducer, with a declarative syntax
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: MockState(subState: 0),
                                                                                      executeOn: MockExecuter()) {
            MockFeedback(effect: effectFunction)
            Reducer(reducerFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducer(MockState.toEmpty, MockEvent.toEmpty)

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

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: MockState(subState: 0),
                                                                                      executeOn: MockExecuter()) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            Reducer(reducerFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducer(MockState.toEmpty, MockEvent.toEmpty)

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

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: MockState(subState: 0),
                                                                                      executeOn: MockExecuter()) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            Reducer(reducerFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducer(MockState.toEmpty, MockEvent.toEmpty)

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

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: MockState(subState: 0),
                                                                                      executeOn: MockExecuter()) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
            Reducer(reducerFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducer(MockState.toEmpty, MockEvent.toEmpty)

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

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        let sut = AnySpin<MockStream<MockState>, MockStream<MockEvent>, MockExecuter>(initialState: MockState(subState: 0),
                                                                                      executeOn: MockExecuter()) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
            MockFeedback(effect: effectEFunction)
            Reducer(reducerFunction)
        }
        _ = sut.effects.forEach { _ = $0(MockStream<MockState>(value: .toEmpty)) }
        _ = sut.reducer(MockState.toEmpty, MockEvent.toEmpty)

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
