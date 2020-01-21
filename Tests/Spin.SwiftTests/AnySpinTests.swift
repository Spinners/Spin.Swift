//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift
import XCTest

final class AnySpinTests: XCTestCase {

    func test_initialize_with_a_feedbackStream_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback stream and a reducer
        var feedbackIsCalled = false
        let feedback = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback stream and reducer
        _ = AnySpin(initialState: MockState(subState: 0), feedbackStream: feedback, reducer: reducer)

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfFeedbacks, 1)
        XCTAssertTrue(feedbackIsCalled)
    }

    func test_initialize_with_a_feedback_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback and a reducer
        var feedbackIsCalled = false
        let effectFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let feedback = MockFeedback(effect: effectFunction)
        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer
        _ = AnySpin(initialState: MockState(subState: 0), feedback: feedback, reducer: reducer)

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(feedbackIsCalled)
    }

    func test_initialize_with_functionBuilder_with_a_feedback_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback and a reducer
        var effectIsCalled = false
        let effectFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(effectIsCalled)
    }

    func test_initialize_with_functionBuilder_with_two_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 2 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_initialize_with_functionBuilder_with_three_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 3 feedback ands a reducer
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectCFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectCIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
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

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectCFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectCIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectDFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectDIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
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

        let effectAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectCFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectCIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectDFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectDIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let effectEFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            effectEIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(effect: effectAFunction)
            MockFeedback(effect: effectBFunction)
            MockFeedback(effect: effectCFunction)
            MockFeedback(effect: effectDFunction)
            MockFeedback(effect: effectEFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(effectEIsCalled)
    }
}
