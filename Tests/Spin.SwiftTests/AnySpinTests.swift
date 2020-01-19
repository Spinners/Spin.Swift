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
        let feedbackFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let feedback = MockFeedback(feedback: feedbackFunction)
        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer
        _ = AnySpin(initialState: MockState(subState: 0), feedback: feedback, reducer: reducer)

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(feedbackIsCalled)
    }

    func test_initialize_with_functionBuilder_with_a_feedback_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: a feedback and a reducer
        var feedbackIsCalled = false
        let feedbackFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedback and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(feedback: feedbackFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(feedbackIsCalled)
    }

    func test_initialize_with_functionBuilder_with_two_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 2 feedback ands a reducer
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false

        let feedbackAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(feedback: feedbackAFunction)
            MockFeedback(feedback: feedbackBFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
    }

    func test_initialize_with_functionBuilder_with_three_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 3 feedback ands a reducer
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false
        var feedbackCIsCalled = false

        let feedbackAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackCFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackCIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(feedback: feedbackAFunction)
            MockFeedback(feedback: feedbackBFunction)
            MockFeedback(feedback: feedbackCFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
        XCTAssertTrue(feedbackCIsCalled)
    }

    func test_initialize_with_functionBuilder_with_four_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 4 feedback ands a reducer
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false
        var feedbackCIsCalled = false
        var feedbackDIsCalled = false

        let feedbackAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackCFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackCIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackDFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackDIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(feedback: feedbackAFunction)
            MockFeedback(feedback: feedbackBFunction)
            MockFeedback(feedback: feedbackCFunction)
            MockFeedback(feedback: feedbackDFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
        XCTAssertTrue(feedbackCIsCalled)
        XCTAssertTrue(feedbackDIsCalled)
    }

    func test_initialize_with_functionBuilder_with_five_feedbacks_and_a_reducer_makes_a_stream_based_on_those_elements() {
        // Given: 4 feedback ands a reducer
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false
        var feedbackCIsCalled = false
        var feedbackDIsCalled = false
        var feedbackEIsCalled = false

        let feedbackAFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackBFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackCFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackCIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackDFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackDIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let feedbackEFunction = { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackEIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        }

        let reducerFunction = { (state: MockState, event: MockAction) -> MockState in
            MockState(subState: 0)
        }

        let reducer = MockReducer(reducer: reducerFunction)

        // When: building an AnySpin based on those feedbacks and reducer, with a declarative syntax
        _ = AnySpin(initialState: MockState(subState: 0), reducer: reducer) {
            MockFeedback(feedback: feedbackAFunction)
            MockFeedback(feedback: feedbackBFunction)
            MockFeedback(feedback: feedbackCFunction)
            MockFeedback(feedback: feedbackDFunction)
            MockFeedback(feedback: feedbackEFunction)
        }

        // Then: the AnySpin initializer produces a reactive stream based on those elements
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
        XCTAssertTrue(feedbackCIsCalled)
        XCTAssertTrue(feedbackDIsCalled)
        XCTAssertTrue(feedbackEIsCalled)
    }
}
