//
//  SpinnerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

@testable import Spin_Swift
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

final class SpinnerTests: XCTestCase {

    func test_Spinner_from_instantiates_a_spinner_with_expected_initialState() {
        // Given: an initial state
        let expectedInitialState = MockState(subState: 1701)

        // When: a Spinner uses the `from` function to build a Spin with the initial state
        let sut = Spinner
            .from(initialState: expectedInitialState)

        // Then: the initial state inside the Spinner is the expected one
        XCTAssertEqual(sut.initialState, expectedInitialState)
    }

    func test_Spinner_add_creates_a_SpinnerFeedback_with_the_provided_feedback() {
        // Given: a Feedback
        var effectsCalled = false
        let feedback = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            effectsCalled = true
            return MockStream<MockEvent>(value: .toEmpty)
        })

        // When: adding this feedback to a Spinner, resulting in a new SpinnerFeedback
        // When: executing the feedback stream held by the SpinnerFeedback
        let sut = Spinner
            .from(initialState: MockState(subState: 1701))
            .add(feedback: feedback)

        _ = MockFeedback(effects: sut.effects).effect(MockStream<MockState>(value: .toEmpty))

        // Then: the SpinnerFeedback has the original initial state
        // Then: the SpinnerFeedback holds the original stream
        XCTAssertEqual(sut.initialState, MockState(subState: 1701))
        XCTAssertTrue(effectsCalled)
    }

    func test_SpinnerFeedback_initializer_preserves_the_feedback_stream() {
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

    func test_SpinnerFeedback_add_preserves_the_feedback_stream() {
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
            .add(feedback: feedbackB)
            .add(feedback: feedbackC)

        _ = MockFeedback(effects: sut.effects).effect(MockStream<MockState>(value: .toEmpty))

        // Then: the SpinnerFeedback has the original initial state
        // Then: the SpinnerFeedback holds the original streams
        XCTAssertEqual(sut.initialState, MockState(subState: 1701))
        XCTAssertEqual(sut.effects.count, 3)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
    }

    func test_SpinnerFeedback_reduce_gives_the_expected_Spin() {
        // Given: an initial state, 2 feedbacks and 1 reducer
        let expectedInitialState = MockState(subState: 1701)
        let feedbackA = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            return MockStream<MockEvent>(value: .toEmpty)
        })
        let feedbackB = MockFeedback(effect: { (states: MockStream<MockState>) -> MockStream<MockEvent> in
            return MockStream<MockEvent>(value: .toEmpty)
        })
        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in return MockState(subState: 1702) }
        
        let reducer = SpyReducer(reducer: reducerFunction)

        // When: using the initial state, the 2 feedbacks and the reducer whithin a Spinner to build a `Spin`
        _ = SpinnerFeedback(initialState: expectedInitialState,
                            feedbacks: [feedbackA, feedbackB])
            .reduce(with: reducer)

        // Then: the reducer is called with the right number of feedbacks
        XCTAssertEqual(reducer.initialState, expectedInitialState)
        XCTAssertTrue(reducer.reduceIsCalled)
        XCTAssertEqual(reducer.numberOfEffects, 2)
    }

    func test_SpinnerFeedback_toReactiveStream_triggers_the_reducer() {
        // Given: an initial state, 2 feedbacks and 1 reducer
        let expectedInitialState = MockState(subState: 1701)
        let feedbackA = MockFeedback(effect: { (states: MockStream<MockState>) in return MockStream<MockEvent>(value: .toEmpty) })
        let feedbackB = MockFeedback(effect: { (states: MockStream<MockState>) in return MockStream<MockEvent>(value: .toEmpty) })
        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in return MockState(subState: 1702) }
        let reducer = SpyReducer(reducer: reducerFunction)

        // When: using the initial state, the 2 feedbacks and the reducer whithin a Spinner until the `toReactiveStream` step to build a stream of `State`
        _ = SpinnerFeedback(initialState: expectedInitialState,
                            feedbacks: [feedbackA, feedbackB])
            .reduce(with: reducer)
            .toReactiveStream()

        // Then: the `Reducer` is triggered
        XCTAssertTrue(reducer.reduceIsCalled)
    }

    func test_SpinnerFeedback_spin_triggers_the_reactiveStream() {
        // Given: an initial state, 2 feedbacks and 1 reducer
        let expectedInitialState = MockState(subState: 1701)
        let feedbackA = MockFeedback(effect: { (states: MockStream<MockState>) in return MockStream<MockEvent>(value: .toEmpty) })
        let feedbackB = MockFeedback(effect: { (states: MockStream<MockState>) in return MockStream<MockEvent>(value: .toEmpty) })
        let reducerFunction = { (state: MockState, event: MockEvent) -> MockState in return MockState(subState: 1702) }
        let reducer = SpyReducer(reducer: reducerFunction)

        // When: using the initial state, the 2 feedbacks and the reducer whithin a Spinner until the `spin` step to trigger a stream of `State`
        _ = SpinnerFeedback(initialState: expectedInitialState,
                            feedbacks: [feedbackA, feedbackB])
            .reduce(with: reducer)
            .spin()

        // Then: the `Reducer` is triggered
        XCTAssertTrue(reducer.reduceIsCalled)
    }
}
