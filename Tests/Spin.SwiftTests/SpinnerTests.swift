//
//  SpinnerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

@testable import Spin_Swift
import XCTest

final class SpinnerTests: XCTestCase {

    func test_Spinner_from_instantiates_a_spinner_with_expected_initialState() {
        // Given: an initial state
        let expectedInitialState = MockState(subState: 1701)

        // When: a Spinner uses the `from` function to build a Spin with the initial state
        let sut = Spinner
            .initialState(expectedInitialState)

        // Then: the initial state inside the Spinner is the expected one
        XCTAssertEqual(sut.initialState, expectedInitialState)
    }

    func test_Spinner_add_creates_a_SpinnerFeedback_with_the_provided_effect() {
        // Given: a Feedback
        var effectsCalled = false
        let feedback = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        })

        // When: adding this feedback to a Spinner, resulting in a new SpinnerFeedback
        // When: executing the feedback stream held by the SpinnerFeedback
        let sut = Spinner
            .initialState(MockState(subState: 1701))
            .feedback(feedback)

        _ = MockFeedback(effects: sut.effects).effect(MockStream<MockState>(value: .toEmpty))

        // Then: the SpinnerFeedback has the original initial state
        // Then: the SpinnerFeedback holds the original stream
        XCTAssertEqual(sut.initialState, MockState(subState: 1701))
        XCTAssertTrue(effectsCalled)
    }

    func test_SpinnerFeedback_initializer_preserves_the_effect_and_initialState() {
        // Given: 2 Feedbacks
        var effectAIsCalled = false
        var effectBIsCalled = false

        let feedbackA = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        })
        let feedbackB = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        })

        // When: adding those feedbacks to a Spinner/SpinnerFeedback
        // When: executing the feedback stream hold by the SpinnerFeedback
        let sut = SpinnerFeedback(initialState: MockState(subState: 1701), feedbacks: [feedbackA, feedbackB])
        _ = MockFeedback(effects: sut.effects).effect(MockStream<MockState>(value: .toEmpty))

        // Then: the SpinnerFeedback has the original initial state
        // Then: the SpinnerFeedback holds the original streams
        XCTAssertEqual(sut.initialState, MockState(subState: 1701))
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_SpinnerFeedback_add_preserves_the_effects() {
        // Given: 3 Feedbacks
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false

        let feedbackA = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectAIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        })
        let feedbackB = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectBIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        })
        let feedbackC = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectCIsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        })

        // When: adding those feedbacks to a Spinner/SpinnerFeedback
        // When: executing the feedback stream hold by the SpinnerFeedback
        let sut = SpinnerFeedback(initialState: MockState(subState: 1701), feedbacks: [feedbackA])
            .feedback(feedbackB)
            .feedback(feedbackC)

        _ = MockFeedback(effects: sut.effects).effect(MockStream<MockState>(value: .toEmpty))

        // Then: the SpinnerFeedback has the original initial state
        // Then: the SpinnerFeedback holds the original streams
        XCTAssertEqual(sut.initialState, MockState(subState: 1701))
        XCTAssertEqual(sut.effects.count, 3)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
    }

    func test_SpinnerFeedback_reduce_preserves_the_reducer() {
        // Given: an initial state, 2 feedbacks and 1 reducer
        let expectedInitialState = MockState(subState: 1701)
        var reducerIsCalled = false

        let feedbackA = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            return MockStream<MockEvent>(value: .toEmpty)
        })
        let feedbackB = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            return MockStream<MockEvent>(value: .toEmpty)
        })
        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in
            reducerIsCalled = true
            return MockState(subState: 1702)
        }
        
        let reducer = MockReducer(reducerFunction)

        // When: using the initial state, the 2 feedbacks and the reducer whithin a Spinner to build a `Spin`
        let sut = SpinnerFeedback(initialState: expectedInitialState,
                                  feedbacks: [feedbackA, feedbackB])
            .reducer(reducer)
        _ = sut.reducerOnExecuter(MockState.toEmpty, MockStream<MockEvent>(value: .toEmpty))

        // Then: the reducer is called with the right number of feedbacks
        XCTAssertEqual(sut.initialState, expectedInitialState)
        XCTAssertEqual(sut.effects.count, 2)
        XCTAssertTrue(reducerIsCalled)
    }
}
