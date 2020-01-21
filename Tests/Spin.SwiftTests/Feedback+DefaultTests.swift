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

    fileprivate init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where FeedbackType.StateStream == StateStream, FeedbackType.EventStream == EventStream {
        let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
            _ = feedbacks.map { $0.effect(stateStream) }
            return .emptyStream()
        }

        self.init(effect: feedback)
    }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

        let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            return .emptyStream()
        }

        self.init(effect: feedback)
     }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB, _ feedbackC: FeedbackTypeC)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeB.StateStream == FeedbackTypeC.StateStream,
                 FeedbackTypeB.EventStream == FeedbackTypeC.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

         let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            _ = feedbackC.effect(stateStream)

            return .emptyStream()
         }

         self.init(effect: feedback)
     }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback>(feedbacks feedbackA: FeedbackTypeA,
                                                                                                                     _ feedbackB: FeedbackTypeB,
                                                                                                                     _ feedbackC: FeedbackTypeC,
                                                                                                                     _ feedbackD: FeedbackTypeD)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeB.StateStream == FeedbackTypeC.StateStream,
                 FeedbackTypeB.EventStream == FeedbackTypeC.EventStream,
                 FeedbackTypeC.StateStream == FeedbackTypeD.StateStream,
                 FeedbackTypeC.EventStream == FeedbackTypeD.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

         let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            _ = feedbackC.effect(stateStream)
            _ = feedbackD.effect(stateStream)

            return .emptyStream()
         }

         self.init(effect: feedback)
     }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, FeedbackTypeE: Feedback>(feedbacks feedbackA: FeedbackTypeA,
                                                                                                                                              _ feedbackB: FeedbackTypeB,
                                                                                                                                              _ feedbackC: FeedbackTypeC,
                                                                                                                                              _ feedbackD: FeedbackTypeD,
                                                                                                                                              _ feedbackE: FeedbackTypeE)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeB.StateStream == FeedbackTypeC.StateStream,
                 FeedbackTypeB.EventStream == FeedbackTypeC.EventStream,
                 FeedbackTypeC.StateStream == FeedbackTypeD.StateStream,
                 FeedbackTypeC.EventStream == FeedbackTypeD.EventStream,
                 FeedbackTypeD.StateStream == FeedbackTypeE.StateStream,
                 FeedbackTypeD.EventStream == FeedbackTypeE.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

         let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            _ = feedbackC.effect(stateStream)
            _ = feedbackD.effect(stateStream)
            _ = feedbackE.effect(stateStream)

            return .emptyStream()
         }

         self.init(effect: feedback)
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

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_a_stream_but_without_executer() {
        // Given: a feedback stream based on a Stream<State> -> Stream<Event>
        var effectIsCalled = false
        let effect: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the stream, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback(effect: effect)
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: .toEmpty))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_executeOn_creates_a_feedback_with_the_expected_executer() {
        // Given: a Feedback without an initial Executer
        let effect: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: applying a new Executer to the Feedback
        let executer = MockExecuter()
        let sut = SpyFeedback(effect: effect).execute(on: executer)

        // Then: the created feedback has the expected Executer
        XCTAssertEqual(executer, sut.feedbackExecuter)
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_an_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithState: MockState?
        let effect: (MockState) -> MockStream<MockAction> = { state -> MockStream<MockAction> in
            effectIsCalled = true
            effectIsCalledWithState = state
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback(effect: effect)
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 0)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithState, MockState(subState: 0))
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_nil_executionStrategy_when_instantiated_with_a_directEffect() {
        // Given: a feedback stream based on a State -> Event
        var effectIsCalled = false
        var effectIsCalledWithState: MockState?
        let effect: (MockState) -> MockAction = { state -> MockAction in
            effectIsCalled = true
            effectIsCalledWithState = state
            return MockAction(value: 10)
        }

        // When: instantiating the feedback with the effect, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback(directEffect: effect)
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 0)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is nil since this is not applicable to a directEffect
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertNil(spyExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithState, MockState(subState: 0))
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_filtered_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithState: MockState?
        let effect: (MockState) -> MockStream<MockAction> = { state -> MockStream<MockAction> in
            effectIsCalled = true
            effectIsCalledWithState = state
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, a filter, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback(effect: effect, filteredBy: { $0.subState > 10 })
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockActionStreamWhenFilteredIsFalse = sut.effect(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithState, MockState(subState: 15))
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
        XCTAssertEqual(receivedMockActionStreamWhenFilteredIsFalse.value, MockAction.toEmpty)
    }

    func test_feedback_is_called_with_substate_when_filteredResult_is_passed_in_the_initializer() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithSubState: Int?
        let effect: (Int) -> MockStream<MockAction> = { subState -> MockStream<MockAction> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, a Result filter, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(effect: effect, filteredByResult: { state in
            if state.subState > 10 {
            return .success(state.subState)
            }

            return .failure(.effectIsNotExecuted)
        })
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockActionStreamWhenFilteredIsFalse = sut.effect(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received subState in the feedback closure is the one returned be the Result filter closure
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
        XCTAssertEqual(receivedMockActionStreamWhenFilteredIsFalse.value, MockAction.toEmpty)
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
        let sut = SpyFeedback<MockState, MockAction>(effect: effect)
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithState, MockState(subState: 10))
        XCTAssertEqual(receivedMockActionStream.value, MockAction.toEmpty)
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_a_voidState_effect_but_without_executer() {
        // Given: a feedback stream based on a () -> Stream<Event>
        var effectIsCalled = false
        let effect: () -> MockStream<MockAction> = { () -> MockStream<MockAction> in
            effectIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(effect: effect)
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is nil since no state stream as an input of the feedback closure
        // Then: the feedback closure given to the feedback is executed and gives a event stream with the awaited MockAction
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertNil(spyExecutionStrategy)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_uifeedbacks_but_without_executer() {
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

        let eventFeedbackStream: () -> MockStream<MockAction> = { () -> MockStream<MockAction> in
            eventFeedbackIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the ui feedbacks, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(uiEffects: stateFeedbackStream, eventFeedbackStream)
        _ = sut.effect(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the state feedback is called witht the awaited state
        // Then: the event feedback closure given to the feedback is executed and gives a event stream with the awaited MockAction
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
        let effect: (Int) -> MockStream<MockAction> = { subState -> MockStream<MockAction> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, a lense, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(effect: effect, lensingOn: { $0.subState })
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_substated_filtered_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Event>
        var effectIsCalled = false
        var effectIsCalledWithSubState: Int?
        let effect: (Int) -> MockStream<MockAction> = { subState -> MockStream<MockAction> in
            effectIsCalled = true
            effectIsCalledWithSubState = subState
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, a lense, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(effect: effect, lensingOn: { $0.subState }, filteredBy: { $0 > 10 })
        let receivedMockActionStream = sut.effect(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockActionStreamWhenFilteredIsFalse = sut.effect(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.effect function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(effectIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
        XCTAssertEqual(receivedMockActionStreamWhenFilteredIsFalse.value, MockAction.toEmpty)
    }

    func test_initialize_with_a_previous_feedback_executes_the_original_feedbackFunction() {
        // Given: a feedback based on a Stream<State> -> Stream<Event>
        var effectIsCalled = false
        let effect: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let sourceFeedback = SpyFeedback(effect: effect)

        // When: instantiating the feedback with an already existing feedback
        // When: executing the feedback
        let sut = SpyFeedback(sourceFeedback)
        _ = sut.effect(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback stream is preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
    }

    func test_initialize_with_functionBuilder_with_a_previous_feedback_executes_the_original_feedbackFunction() {
        // Given: a feedback based on a Stream<State> -> Stream<Event>
        var effectIsCalled = false
        let effectStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let sourceFeedback = SpyFeedback(effect: effectStream)

        // When: instantiating the feedback with an already existing feedback with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedback
        }

        _ = sut.effect(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback stream is preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectIsCalled)
    }

    func test_initialize_with_functionBuilder_with_two_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 2 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false

        let effectAStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectBStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(effect: effectAStream)
        let sourceFeedbackB = SpyFeedback(effect: effectBStream)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback{
            sourceFeedbackA
            sourceFeedbackB
        }

        _ = sut.effect(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_initialize_with_functionBuilder_with_three_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 3 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false

        let effectAStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectBStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectCStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectCIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(effect: effectAStream)
        let sourceFeedbackB = SpyFeedback(effect: effectBStream)
        let sourceFeedbackC = SpyFeedback(effect: effectCStream)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedbackA
            sourceFeedbackB
            sourceFeedbackC
        }

        _ = sut.effect(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
    }

    func test_initialize_with_functionBuilder_with_four_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 4 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false

        let effectAStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectBStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectCStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectCIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectDStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectDIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(effect: effectAStream)
        let sourceFeedbackB = SpyFeedback(effect: effectBStream)
        let sourceFeedbackC = SpyFeedback(effect: effectCStream)
        let sourceFeedbackD = SpyFeedback(effect: effectDStream)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedbackA
            sourceFeedbackB
            sourceFeedbackC
            sourceFeedbackD
        }

        _ = sut.effect(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
    }

    func test_initialize_with_functionBuilder_with_five_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 5 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false
        var effectEIsCalled = false

        let effectA: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectB: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectC: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectCIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectD: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectDIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let effectE: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            effectEIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(effect: effectA)
        let sourceFeedbackB = SpyFeedback(effect: effectB)
        let sourceFeedbackC = SpyFeedback(effect: effectC)
        let sourceFeedbackD = SpyFeedback(effect: effectD)
        let sourceFeedbackE = SpyFeedback(effect: effectE)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedbackA
            sourceFeedbackB
            sourceFeedbackC
            sourceFeedbackD
            sourceFeedbackE
        }

        _ = sut.effect(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(effectEIsCalled)
    }

    func test_initialize_when_called_with_two_partial_feedbacks_executes_the_original_feedbackFunctions() throws {
        var stateFeedbackIsCalled = false
        var receivedState: MockState = .toEmpty
        var eventFeedbackIsCalled = false

        // Given: 2 partial streams
        let stateStream = { (state: MockState) -> Void in
            stateFeedbackIsCalled = true
            receivedState = state
        }

        let eventStream = { () -> MockStream<MockAction> in
            eventFeedbackIsCalled = true
            return .empty()
        }

        // Given: a full stream built based on the partial ones
        let sut = MockFeedback(uiEffects: stateStream, eventStream)

        // When: feeding this stream with 1 input
        _ = sut.effect(MockStream<MockState>(value: MockState(subState: 1701)))

        // Then: the stream triggers the 2 partials feedbacks
        XCTAssertTrue(stateFeedbackIsCalled)
        XCTAssertTrue(eventFeedbackIsCalled)
        XCTAssertEqual(receivedState, MockState(subState: 1701))
    }
}
