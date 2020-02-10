//
//  Feedback+DefaultTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

import Spin_Swift
import XCTest

fileprivate struct SpyFeedback<State: CanBeEmpty, Event: CanBeEmpty>: Feedback {

    fileprivate typealias StateStream = MockStream<State>
    fileprivate typealias EventStream = MockStream<Event>
    fileprivate typealias Executer = MockExecuter

    fileprivate var effect: (StateStream) -> EventStream
    fileprivate var feedbackExecuter: Executer?

    fileprivate var initIsCalled = false

    fileprivate init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        self.effect = effect
        self.feedbackExecuter = executer
        self.initIsCalled = true
    }

    fileprivate init(effect: @escaping (StateStream.Value) -> EventStream,
                on executer: Executer? = nil,
                applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        spyExecutionStrategy = strategy

        let fullEffect: (StateStream) -> EventStream = { states in
            return states.flatMap(effect)
        }

        self.init(effect: fullEffect, on: executer)
    }

    fileprivate init(directEffect: @escaping (StateStream.Value) -> EventStream.Value, on executer: Executer? = nil) {
        let fullEffect: (StateStream) -> EventStream = { states in
            return states.map(directEffect)
        }

        self.init(effect: fullEffect, on: executer)
    }

    fileprivate init(effects: [(StateStream) -> EventStream]) {
        let effect: (StateStream) -> EventStream = { states in
            _ = effects.map { $0(states) }
            return .emptyStream()
        }

        self.init(effect: effect, on: nil)
    }
}

private var spyExecutionStrategy: ExecutionStrategy? = nil

final class Feedback_DefaultTests: XCTestCase {

    override func setUp() {
        super.setUp()
        spyExecutionStrategy = nil
    }

    override class func tearDown() {
        spyExecutionStrategy = nil
    }

    func test_executeOn_creates_a_feedback_with_the_expected_executer() {
        // Given: a Feedback without an initial Executer
        let effect: (MockStream<MockState>) -> MockStream<MockEvent> = { states -> MockStream<MockEvent> in
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: applying a new Executer to the Feedback
        let executer = MockExecuter()
        let sut = SpyFeedback(effect: effect).execute(on: executer)

        // Then: the created feedback has the expected Executer
        XCTAssertEqual(executer, sut.feedbackExecuter)
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_filtered_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithState: MockState?
        let effect: (MockState) -> MockStream<MockEvent> = { state -> MockStream<MockEvent> in
            effectIsCalled = true
            effectIsCalledWithState = state
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the effect, a filter, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback(effect: effect, filteredBy: { $0.subState > 10 })
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockEventStreamWhenFilteredIsFalse = sut.effect(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockEvent>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithState, MockState(subState: 15))
        XCTAssertEqual(receivedMockEventStream.value, MockEvent(value: 10))
        XCTAssertEqual(receivedMockEventStreamWhenFilteredIsFalse.value, MockEvent.toEmpty)
    }

    func test_feedback_is_called_with_substate_when_filteredResult_is_passed_in_the_initializer() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithSubState: Int?
        let effect: (Int) -> MockStream<MockEvent> = { subState -> MockStream<MockEvent> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the effect, a Result filter, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(effect: effect, filteredByResult: { state in
            if state.subState > 10 {
            return .success(state.subState)
            }

            return .failure(.effectIsNotExecuted)
        })
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockEventStreamWhenFilteredIsFalse = sut.effect(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received subState in the feedback closure is the one returned be the Result filter closure
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockEvent>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockEventStream.value, MockEvent(value: 10))
        XCTAssertEqual(receivedMockEventStreamWhenFilteredIsFalse.value, MockEvent.toEmpty)
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_a_voidEvent_effect_but_without_executer() {
        // Given: a feedback stream based on a State -> Void
        var effectIsCalled = false
        var effectIsCalledWithState: MockState?
        let effect: (MockState) -> Void = { state -> Void in
            effectIsCalled = true
            effectIsCalledWithState = state
            return ()
        }

        // When: instantiating the feedback with the effect, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(effect: effect)
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockEvent>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithState, MockState(subState: 10))
        XCTAssertEqual(receivedMockEventStream.value, MockEvent.toEmpty)
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_a_voidState_effect_but_without_executer() {
        // Given: a feedback stream based on a () -> Stream<Event>
        var effectIsCalled = false
        let effect: () -> MockStream<MockEvent> = { () -> MockStream<MockEvent> in
            effectIsCalled = true
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the effect, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(effect: effect)
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is nil since no state stream as an input of the feedback closure
        // Then: the feedback closure given to the feedback is executed and gives a event stream with the awaited MockEvent
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertNil(spyExecutionStrategy)
        XCTAssertEqual(receivedMockEventStream.value, MockEvent(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_uiEffects_but_without_executer() {
        // Given: a feedback stream based on a State -> Void
        // Given: a feedback stream based on a () -> Stream<Event>
        var stateFeedbackIsCalled = false
        var eventFeedbackIsCalled = false

        var feedbackIsCalledWithState: MockState?

        let stateFeedbackStream: (MockState) -> Void = { state -> Void in
            stateFeedbackIsCalled = true
            feedbackIsCalledWithState = state
            return ()
        }

        let eventFeedbackStream: () -> MockStream<MockEvent> = { () -> MockStream<MockEvent> in
            eventFeedbackIsCalled = true
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the ui feedbacks, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(uiEffects: stateFeedbackStream, eventFeedbackStream)
        _ = sut.effect(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the state feedback is called witht the awaited state
        // Then: the event feedback closure given to the feedback is executed and gives a event stream with the awaited MockEvent
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(stateFeedbackIsCalled)
        XCTAssertTrue(eventFeedbackIsCalled)
        XCTAssertEqual(feedbackIsCalledWithState, MockState(subState: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_substated_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithSubState: Int?
        let effect: (Int) -> MockStream<MockEvent> = { subState -> MockStream<MockEvent> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the effect, a lense, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(effect: effect, lensingOn: { $0.subState })
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockEvent>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockEventStream.value, MockEvent(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_keypath_substated_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithSubState: Int?
        let effect: (Int) -> MockStream<MockEvent> = { subState -> MockStream<MockEvent> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the effect, a keyPath, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(effect: effect, lensingOn: \.subState)
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockEvent>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockEventStream.value, MockEvent(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_substated_filtered_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithSubState: Int?
        let effect: (Int) -> MockStream<MockEvent> = { subState -> MockStream<MockEvent> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the effect, a lense, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(effect: effect, lensingOn: { $0.subState }, filteredBy: { $0 > 10 })
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockEventStreamWhenFilteredIsFalse = sut.effect(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockEvent>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockEventStream.value, MockEvent(value: 10))
        XCTAssertEqual(receivedMockEventStreamWhenFilteredIsFalse.value, MockEvent.toEmpty)
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_keypath_substated_filtered_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithSubState: Int?
        let effect: (Int) -> MockStream<MockEvent> = { subState -> MockStream<MockEvent> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockEvent>(value: MockEvent(value: 10))
        }

        // When: instantiating the feedback with the effect, a lense, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockEvent>(effect: effect, lensingOn: \.subState, filteredBy: { $0 > 10 })
        let receivedMockEventStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockEventStreamWhenFilteredIsFalse = sut.effect(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockEvent>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockEventStream.value, MockEvent(value: 10))
        XCTAssertEqual(receivedMockEventStreamWhenFilteredIsFalse.value, MockEvent.toEmpty)
    }
}
