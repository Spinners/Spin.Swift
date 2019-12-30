//
//  Feedback+DefaultTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

import Spin_Swift
import XCTest

fileprivate struct SpyFeedback<State: CanBeEmpty, Mutation: CanBeEmpty>: Feedback {

    fileprivate typealias StreamState = MockStream<State>
    fileprivate typealias StreamMutation = MockStream<Mutation>
    fileprivate typealias Executer = MockExecuter

    fileprivate var feedbackStream: (StreamState) -> StreamMutation
    fileprivate var feedbackExecuter: Executer?

    fileprivate var initIsCalled = false

    fileprivate init(feedback: @escaping (StreamState) -> StreamMutation, on executer: Executer? = nil) {
        self.feedbackStream = feedback
        self.feedbackExecuter = executer
        self.initIsCalled = true
    }

    fileprivate init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where FeedbackType.StreamState == StreamState, FeedbackType.StreamMutation == StreamMutation {
        let feedback = { (stateStream: FeedbackType.StreamState) -> FeedbackType.StreamMutation in
            _ = feedbacks.map { $0.feedbackStream(stateStream) }
            return .emptyStream()
        }

        self.init(feedback: feedback)
    }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

        let feedback: (StreamState) -> StreamMutation = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            return .emptyStream()
        }

        self.init(feedback: feedback)
     }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB, _ feedbackC: FeedbackTypeC)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

         let feedback: (StreamState) -> StreamMutation = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback>(feedbacks feedbackA: FeedbackTypeA,
                                                                                                                     _ feedbackB: FeedbackTypeB,
                                                                                                                     _ feedbackC: FeedbackTypeC,
                                                                                                                     _ feedbackD: FeedbackTypeD)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                 FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                 FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

         let feedback: (StreamState) -> StreamMutation = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)
            _ = feedbackD.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    fileprivate init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, FeedbackTypeE: Feedback>(feedbacks feedbackA: FeedbackTypeA,
                                                                                                                                              _ feedbackB: FeedbackTypeB,
                                                                                                                                              _ feedbackC: FeedbackTypeC,
                                                                                                                                              _ feedbackD: FeedbackTypeD,
                                                                                                                                              _ feedbackE: FeedbackTypeE)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                 FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                 FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                 FeedbackTypeD.StreamState == FeedbackTypeE.StreamState,
                 FeedbackTypeD.StreamMutation == FeedbackTypeE.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

         let feedback: (StreamState) -> StreamMutation = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)
            _ = feedbackD.feedbackStream(stateStream)
            _ = feedbackE.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    fileprivate static func make(from effect: @escaping (StreamState.Value) -> StreamMutation, applying strategy: ExecutionStrategy) -> (StreamState) -> StreamMutation {
        spyExecutionStrategy = strategy

        let feedbackFromEffectStream: (StreamState) -> StreamMutation = { states in
            return states.flatMap(effect)
        }

        return feedbackFromEffectStream
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
        // Given: a feedback stream based on a Stream<State> -> Stream<Mutation>
        var feedbackIsCalled = false
        let feedbackStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the stream, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback(feedback: feedbackStream)
        let receivedMockActionStream = sut.feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_executeOn_creates_a_feedback_with_the_expected_executer() {
        // Given: a Feedback without an initial Executer
        let feedbackStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: applying a new Executer to the Feedback
        let executer = MockExecuter()
        let sut = SpyFeedback(feedback: feedbackStream).execute(on: executer)

        // Then: the created feedback has the expected Executer
        XCTAssertEqual(executer, sut.feedbackExecuter)
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_an_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Mutation>
        var feedbackIsCalled = false
        var feedbackIsCalledWithState: MockState?
        let feedbackStream: (MockState) -> MockStream<MockAction> = { state -> MockStream<MockAction> in
            feedbackIsCalled = true
            feedbackIsCalledWithState = state
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback(feedback: feedbackStream)
        let receivedMockActionStream = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 0)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.execute function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(feedbackIsCalledWithState, MockState(subState: 0))
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_filtered_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Mutation>
        var feedbackIsCalled = false
        var feedbackIsCalledWithState: MockState?
        let feedbackStream: (MockState) -> MockStream<MockAction> = { state -> MockStream<MockAction> in
            feedbackIsCalled = true
            feedbackIsCalledWithState = state
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, a filter, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback(feedback: feedbackStream, filteredBy: { $0.subState > 10 })
        let receivedMockActionStream = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockActionStreamWhenFilteredIsFalse = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.execute function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(feedbackIsCalledWithState, MockState(subState: 15))
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
        XCTAssertEqual(receivedMockActionStreamWhenFilteredIsFalse.value, MockAction.toEmpty)
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_a_voidMutation_effect_but_without_executer() {
        // Given: a feedback stream based on a State -> Void
        var feedbackIsCalled = false
        var feedbackIsCalledWithState: MockState?
        let feedbackStream: (MockState) -> Void = { state -> Void in
            feedbackIsCalled = true
            feedbackIsCalledWithState = state
            return ()
        }

        // When: instantiating the feedback with the effect, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(feedback: feedbackStream)
        let receivedMockActionStream = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.execute function
        // Then: the feedback closure given to the feedback is executed and gives an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(feedbackIsCalledWithState, MockState(subState: 10))
        XCTAssertEqual(receivedMockActionStream.value, MockAction.toEmpty)
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_a_voidState_effect_but_without_executer() {
        // Given: a feedback stream based on a () -> Stream<Mutation>
        var feedbackIsCalled = false
        let feedbackStream: () -> MockStream<MockAction> = { () -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(feedback: feedbackStream)
        let receivedMockActionStream = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is nil since no state stream as an input of the feedback closure
        // Then: the feedback closure given to the feedback is executed and gives a mutation stream with the awaited MockAction
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertNil(spyExecutionStrategy)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_when_instantiated_with_uifeedbacks_but_without_executer() {
        // Given: a feedback stream based on a State -> Void
        // Given: a feedback stream based on a () -> Stream<Mutation>
        var stateFeedbackIsCalled = false
        var mutationFeedbackIsCalled = false

        var feedbackIsCalledWithState: MockState?

        let stateFeedbackStream: (MockState) -> Void = { state -> Void in
            stateFeedbackIsCalled = true
            feedbackIsCalledWithState = state
            return ()
        }

        let mutationFeedbackStream: () -> MockStream<MockAction> = { () -> MockStream<MockAction> in
            mutationFeedbackIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the ui feedbacks, and no Executer
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(uiFeedbacks: stateFeedbackStream, mutationFeedbackStream)
        _ = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 10)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the state feedback is called witht the awaited state
        // Then: the mutation feedback closure given to the feedback is executed and gives a mutation stream with the awaited MockAction
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(stateFeedbackIsCalled)
        XCTAssertTrue(mutationFeedbackIsCalled)
        XCTAssertEqual(feedbackIsCalledWithState, MockState(subState: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_substated_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Mutation>
        var feedbackIsCalled = false
        var feedbackIsCalledWithSubState: Int?
        let feedbackStream: (Int) -> MockStream<MockAction> = { subState -> MockStream<MockAction> in
            feedbackIsCalled = true
            feedbackIsCalledWithSubState = subState
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, a lense, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(feedback: feedbackStream, lensingOn: { $0.subState })
        let receivedMockActionStream = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 15)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.execute function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(feedbackIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
    }

    func test_initializer_is_called_with_nil_executer_and_default_executionStrategy_when_instantiated_with_a_substated_filtered_effect_but_without_executer_and_without_an_executionStrategy() {
        // Given: a feedback stream based on a State -> Stream<Mutation>
        var feedbackIsCalled = false
        var feedbackIsCalledWithSubState: Int?
        let feedbackStream: (Int) -> MockStream<MockAction> = { subState -> MockStream<MockAction> in
            feedbackIsCalled = true
            feedbackIsCalledWithSubState = subState
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        // When: instantiating the feedback with the effect, a lense, and no Executer, and no execution strategy
        // When: executing the feedback
        let sut = SpyFeedback<MockState, MockAction>(feedback: feedbackStream, lensingOn: { $0.subState }, filteredBy: { $0 > 10 })
        let receivedMockActionStream = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 15)))
        let receivedMockActionStreamWhenFilteredIsFalse = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 5)))

        // Then: the default initializer of the feedback is called
        // Then: the Executer inside the feedback is nil
        // Then: the ExecutionStrategy is the default one
        // Then: the received state in the feedback closure is the one passed to the feedback.execute function
        // Then: the feedback closure given to the feedback is executed and gives the expected result
        // Then: the received element from the feedback when the filter is false is an empty stream
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(spyExecutionStrategy, MockFeedback<MockState, MockAction>.defaultExecutionStrategy)
        XCTAssertEqual(feedbackIsCalledWithSubState, 15)
        XCTAssertEqual(receivedMockActionStream.value, MockAction(value: 10))
        XCTAssertEqual(receivedMockActionStreamWhenFilteredIsFalse.value, MockAction.toEmpty)
    }

    func test_initialize_with_a_previous_feedback_executes_the_original_feedbackFunction() {
        // Given: a feedback based on a Stream<State> -> Stream<Mutation>
        var feedbackIsCalled = false
        let feedbackStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let sourceFeedback = SpyFeedback(feedback: feedbackStream)

        // When: instantiating the feedback with an already existing feedback
        // When: executing the feedback
        let sut = SpyFeedback(sourceFeedback)
        _ = sut.feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback stream is preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
    }

    func test_initialize_with_functionBuilder_with_a_previous_feedback_executes_the_original_feedbackFunction() {
        // Given: a feedback based on a Stream<State> -> Stream<Mutation>
        var feedbackIsCalled = false
        let feedbackStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let sourceFeedback = SpyFeedback(feedback: feedbackStream)

        // When: instantiating the feedback with an already existing feedback with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedback
        }

        _ = sut.feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback stream is preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackIsCalled)
    }

    func test_initialize_with_functionBuilder_with_two_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 2 feedbacks based on a Stream<State> -> Stream<Mutation>
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false

        let feedbackAStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackBStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(feedback: feedbackAStream)
        let sourceFeedbackB = SpyFeedback(feedback: feedbackBStream)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback{
            sourceFeedbackA
            sourceFeedbackB
        }

        _ = sut.feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
    }

    func test_initialize_with_functionBuilder_with_three_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 3 feedbacks based on a Stream<State> -> Stream<Mutation>
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false
        var feedbackCIsCalled = false

        let feedbackAStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackBStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackCStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackCIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(feedback: feedbackAStream)
        let sourceFeedbackB = SpyFeedback(feedback: feedbackBStream)
        let sourceFeedbackC = SpyFeedback(feedback: feedbackCStream)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedbackA
            sourceFeedbackB
            sourceFeedbackC
        }

        _ = sut.feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
        XCTAssertTrue(feedbackCIsCalled)
    }

    func test_initialize_with_functionBuilder_with_four_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 4 feedbacks based on a Stream<State> -> Stream<Mutation>
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false
        var feedbackCIsCalled = false
        var feedbackDIsCalled = false

        let feedbackAStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackBStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackCStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackCIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackDStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackDIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(feedback: feedbackAStream)
        let sourceFeedbackB = SpyFeedback(feedback: feedbackBStream)
        let sourceFeedbackC = SpyFeedback(feedback: feedbackCStream)
        let sourceFeedbackD = SpyFeedback(feedback: feedbackDStream)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedbackA
            sourceFeedbackB
            sourceFeedbackC
            sourceFeedbackD
        }

        _ = sut.feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
        XCTAssertTrue(feedbackCIsCalled)
        XCTAssertTrue(feedbackDIsCalled)
    }

    func test_initialize_with_functionBuilder_with_five_feedbacks_executes_the_original_feedbackFunctions() {
        // Given: 5 feedbacks based on a Stream<State> -> Stream<Mutation>
        var feedbackAIsCalled = false
        var feedbackBIsCalled = false
        var feedbackCIsCalled = false
        var feedbackDIsCalled = false
        var feedbackEIsCalled = false

        let feedbackAStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackAIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackBStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackBIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackCStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackCIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackDStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackDIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }
        let feedbackEStream: (MockStream<MockState>) -> MockStream<MockAction> = { states -> MockStream<MockAction> in
            feedbackEIsCalled = true
            return MockStream<MockAction>(value: MockAction(value: 10))
        }

        let sourceFeedbackA = SpyFeedback(feedback: feedbackAStream)
        let sourceFeedbackB = SpyFeedback(feedback: feedbackBStream)
        let sourceFeedbackC = SpyFeedback(feedback: feedbackCStream)
        let sourceFeedbackD = SpyFeedback(feedback: feedbackDStream)
        let sourceFeedbackE = SpyFeedback(feedback: feedbackEStream)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = SpyFeedback {
            sourceFeedbackA
            sourceFeedbackB
            sourceFeedbackC
            sourceFeedbackD
            sourceFeedbackE
        }

        _ = sut.feedbackStream(MockStream<MockState>(value: .toEmpty))

        // Then: the default init of the Feedback is called
        // Then: the Executer passed to the init is nil
        // Then: the original feedback streams are preserved
        XCTAssertTrue(sut.initIsCalled)
        XCTAssertNil(sut.feedbackExecuter)
        XCTAssertTrue(feedbackAIsCalled)
        XCTAssertTrue(feedbackBIsCalled)
        XCTAssertTrue(feedbackCIsCalled)
        XCTAssertTrue(feedbackDIsCalled)
        XCTAssertTrue(feedbackEIsCalled)
    }

    func test_initialize_when_called_with_two_partial_feedbacks_executes_the_original_feedbackFunctions() throws {
        var stateFeedbackIsCalled = false
        var receivedState: MockState = .toEmpty
        var mutationFeedbackIsCalled = false

        // Given: 2 partial streams
        let stateStream = { (state: MockState) -> Void in
            stateFeedbackIsCalled = true
            receivedState = state
        }

        let mutationStream = { () -> MockStream<MockAction> in
            mutationFeedbackIsCalled = true
            return .empty()
        }

        // Given: a full stream built based on the partial ones
        let sut = MockFeedback(uiFeedbacks: stateStream, mutationStream)

        // When: feeding this stream with 1 input
        _ = sut.feedbackStream(MockStream<MockState>(value: MockState(subState: 1701)))

        // Then: the stream triggers the 2 partials feedbacks
        XCTAssertTrue(stateFeedbackIsCalled)
        XCTAssertTrue(mutationFeedbackIsCalled)
        XCTAssertEqual(receivedState, MockState(subState: 1701))
    }
}
