//
//  SpinnerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

@testable import Spin_Swift
import XCTest

final class SpinnerTests: XCTestCase {

    func test_spinner_from_instantiates_a_spinner_with_expected_initialState() {
        // Given: an initial state
        let expectedInitialState = MockState(subState: 1701)

        // When: a Spinner uses the `from` function to build a Spin with the initial state
        let sut = Spinner
            .from(initialState: expectedInitialState)

        // Then: the initial state inside the Spinner is the expected one
        XCTAssertEqual(sut.initialState, expectedInitialState)
    }

    func test_spinner_add_creates_a_SpinnerFeedback_with_the_provided_feedback() {
        // Given: a Feedback
        var feedbackIsCalled = false
        let feedback = MockFeedback(feedback: { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        })

        // When: adding this feedback to a Spinner, resulting in a new SpinnerFeedback
        // When: executing the feedback stream hold by the SpinnerFeedback
        let sut = Spinner
            .from(initialState: MockState(subState: 1701))
            .add(feedback: feedback)

        _ = MockFeedback(sut.feedbackStreams).feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the SpinnerFeedback has the original initial state
        // Then: the SpinnerFeedback holds the original stream
        XCTAssertEqual(sut.initialState, MockState(subState: 1701))
        XCTAssertTrue(feedbackIsCalled)
    }

    func test_SpinnerFeedback_add_preserves_the_feedback_stream() {
        // Given: 2 Feedbacks
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false

        let feedbackA = MockFeedback(feedback: { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        })
        let feedbackB = MockFeedback(feedback: { (states: MockStream<MockState>) -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: .toEmpty)
        })

        // When: adding those feedbacks to a Spinner/SpinnerFeedback
        // When: executing the feedback stream hold by the SpinnerFeedback
        let sut = Spinner
            .from(initialState: MockState(subState: 1701))
            .add(feedback: feedbackA)
            .add(feedback: feedbackB)
        _ = MockFeedback(sut.feedbackStreams).feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the SpinnerFeedback has the original initial state
        // Then: the SpinnerFeedback holds the original streams
        XCTAssertEqual(sut.initialState, MockState(subState: 1701))
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
    }

    func test_reduce_gives_the_expected_Spin() {
        // Given: an initial state, 2 feedbacks and 1 reducer
        let expectedInitialState = MockState(subState: 1701)
        let feedbackA = MockFeedback(feedback: { (states: MockStream<MockState>) -> MockStream<MockAction> in
            return MockStream<MockAction>(value: .toEmpty)
        })
        let feedbackB = MockFeedback(feedback: { (states: MockStream<MockState>) -> MockStream<MockAction> in
            return MockStream<MockAction>(value: .toEmpty)
        })
        let reducerFunction = { (state: MockState, action: MockAction) -> MockState in return MockState(subState: 1702) }
        let reducer = MockReducer(reducer: reducerFunction)

        // When: using the initial state, the 2 feedbacks and the reducer whithin a Spinner to build a `Spin`
        _ = Spinner
            .from(initialState: expectedInitialState)
            .add(feedback: feedbackA)
            .add(feedback: feedbackB)
            .reduce(with: reducer)

        // Then: the reducer is called with the right number of feedbacks
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfFeedbacks, 2)
    }

    func test_toReactiveStream_triggers_the_reducer() {
        // Given: an initial state, 2 feedbacks and 1 reducer
        let expectedInitialState = MockState(subState: 1701)
        let feedbackA = MockFeedback(feedback: { (states: MockStream<MockState>) in return MockStream<MockAction>(value: .toEmpty) })
        let feedbackB = MockFeedback(feedback: { (states: MockStream<MockState>) in return MockStream<MockAction>(value: .toEmpty) })
        let reducerFunction = { (state: MockState, action: MockAction) -> MockState in return MockState(subState: 1702) }
        let reducer = MockReducer(reducer: reducerFunction)

        // When: using the initial state, the 2 feedbacks and the reducer whithin a Spinner until the `toReactiveStream` step to build a stream of `State`
        _ = Spinner
            .from(initialState: expectedInitialState)
            .add(feedback: feedbackA)
            .add(feedback: feedbackB)
            .reduce(with: reducer)
            .toReactiveStream()

        // Then: the `Reducer` is triggered
        XCTAssertTrue(reducer.reduceIsCalled)
    }

    func test_spin_triggers_the_reactiveStream() {
        // Given: an initial state, 2 feedbacks and 1 reducer
        let expectedInitialState = MockState(subState: 1701)
        let feedbackA = MockFeedback(feedback: { (states: MockStream<MockState>) in return MockStream<MockAction>(value: .toEmpty) })
        let feedbackB = MockFeedback(feedback: { (states: MockStream<MockState>) in return MockStream<MockAction>(value: .toEmpty) })
        let reducerFunction = { (state: MockState, action: MockAction) -> MockState in return MockState(subState: 1702) }
        let reducer = MockReducer(reducer: reducerFunction)

        // When: using the initial state, the 2 feedbacks and the reducer whithin a Spinner until the `spin` step to trigger a stream of `State`
        _ = Spinner
            .from(initialState: expectedInitialState)
            .add(feedback: feedbackA)
            .add(feedback: feedbackB)
            .reduce(with: reducer)
            .spin()

        // Then: the `Reducer` is triggered
        XCTAssertTrue(reducer.reduceIsCalled)
    }
}
