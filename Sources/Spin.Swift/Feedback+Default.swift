//
//  Feedback+Default.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

public extension Feedback {

    static var defaultExecutionStrategy: ExecutionStrategy {
        return .cancelOnNewEvent
    }

    /// Set an executer for the feedback after its initilization
    /// - Parameter executer: the executer on which the feedback (the underlying reactive streams) will be executed
    func execute(on executer: Executer) -> Self {
        let newFeedback = Self(feedback: self.feedbackStream, on: executer)
        return newFeedback
    }

    init<StreamStateType: ReactiveStream, StreamMutationType: ReactiveStream>(_ feedbackStreams: [(StreamState) -> StreamMutation])
        where   StreamStateType == StreamState,
                StreamMutationType == StreamMutation {
        let feedbacks = feedbackStreams.map { Self(feedback: $0, on: nil) }

        self.init(feedbacks: feedbacks)
    }

    init<FeedbackType: Feedback>(_ feedback: FeedbackType)
        where   FeedbackType.StreamState == StreamState,
                FeedbackType.StreamMutation == StreamMutation,
                FeedbackType.Executer == Executer {
            self.init(feedback: feedback.feedbackStream, on: nil)
    }

    init<FeedbackType: Feedback>(@FeedbackBuilder builder: () -> FeedbackType)
        where   FeedbackType.StreamState == StreamState,
                FeedbackType.StreamMutation == StreamMutation {
            let feedback = builder()
            self.init(feedback: feedback.feedbackStream, on: nil)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(@FeedbackBuilder builder: () -> (FeedbackTypeA, FeedbackTypeB))
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeA.StreamState == StreamState,
        FeedbackTypeA.StreamMutation == StreamMutation {
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            self.init(feedbacks: feedbackA, feedbackB)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(@FeedbackBuilder builder: () -> (FeedbackTypeA, FeedbackTypeB,  FeedbackTypeC))
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeA.StreamState == StreamState,
                FeedbackTypeA.StreamMutation == StreamMutation {
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            let feedbackC = feedbacks.2
            self.init(feedbacks: feedbackA, feedbackB, feedbackC)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback>(@FeedbackBuilder builder: () -> (FeedbackTypeA, FeedbackTypeB, FeedbackTypeC, FeedbackTypeD))
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                FeedbackTypeA.StreamState == StreamState,
                FeedbackTypeA.StreamMutation == StreamMutation {
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            let feedbackC = feedbacks.2
            let feedbackD = feedbacks.3
            self.init(feedbacks: feedbackA, feedbackB, feedbackC, feedbackD)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, FeedbackTypeE: Feedback>(@FeedbackBuilder builder: () -> ( FeedbackTypeA,
                                                                                                                                                                        FeedbackTypeB,
                                                                                                                                                                        FeedbackTypeC,
                                                                                                                                                                        FeedbackTypeD,
                                                                                                                                                                        FeedbackTypeE))
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
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            let feedbackC = feedbacks.2
            let feedbackD = feedbacks.3
            let feedbackE = feedbacks.4
            self.init(feedbacks: feedbackA, feedbackB, feedbackC, feedbackD, feedbackE)
    }

    /// Initialize the feedback with a: State -> ReactiveStream<Mutation> stream
    /// - Parameters:
    ///   - feedback: the function transforming a `State` to a reactive stream of `Mutation`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while the previous execution is still in progress
    init(feedback: @escaping (StreamState.Value) -> StreamMutation,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedbackStreamFromEffect = Self.make(from: feedback, applying: strategy)
        self.init(feedback: feedbackStreamFromEffect, on: executer)
    }

    /// Initialize the feedback with a: State -> ReactiveStream<Mutation> stream, dismissing the `State` values that don't match the filter
    /// - Parameters:
    ///   - feedback: the function transforming a `State` to a reactive stream of `Mutation`
    ///   - filter: the filter to apply to the input `State`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while the previous execution is still in progress
    init(feedback: @escaping (StreamState.Value) -> StreamMutation,
         filteredBy filter: @escaping (StreamState.Value) -> Bool,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedbackFromStateValueWithFilter: (StreamState.Value) -> StreamMutation = { state -> StreamMutation in
            guard filter(state) else {
                return StreamMutation.emptyStream()
            }

            return feedback(state)

        }

        self.init(feedback: feedbackFromStateValueWithFilter, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: State -> Void stream
    /// - Parameters:
    ///   - feedback: the function transforming a `State` to a Void output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(feedback: @escaping (StreamState.Value) -> Void, on executer: Executer? = nil) {
        let feedbackFromStateValue: (StreamState.Value) -> StreamMutation = { state -> StreamMutation in
            feedback(state)
            return StreamMutation.emptyStream()
        }

        self.init(feedback: feedbackFromStateValue, on: executer, applying: Self.defaultExecutionStrategy)
    }

    /// Initialize the feedback with a: Void -> ReactiveStream<Mutation> stream
    /// - Parameters:
    ///   - feedback: the function transforming a Void input to a ReactiveStream<Mutation> output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(feedback: @escaping () -> StreamMutation, on executer: Executer? = nil) {
        let feedbackFromStateStream: (StreamState) -> StreamMutation = { _ -> StreamMutation in
            return feedback()
        }

        self.init(feedback: feedbackFromStateStream, on: executer)
    }

    /// Initialize the feedback with 2 partial feedbacks. Those 2 partial feedbacks will be concatenated to become a complete ReactiveStream<State> -> ReactiveStream<Mutation> feedback
    /// - Parameters:
    ///   - stateInterpret: the function transforming a `State` to a Void output
    ///   - mutationEmitter: the function transforming a Void input to a ReactiveStream<Mutation> output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(uiFeedbacks stateInterpret: @escaping (StreamState.Value) -> Void, _ mutationEmitter: @escaping () -> StreamMutation, on executer: Executer? = nil) {
        let stateFeedback = Self.init(feedback: stateInterpret, on: executer)
        let mutationFeedback = Self.init(feedback: mutationEmitter, on: executer)

        self.init(feedbacks: stateFeedback, mutationFeedback)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Mutation> stream
    /// - Parameters:
    ///   - feedback: the function transforming a `SubState` to a reactive stream of `Mutation`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type paased as an input to the feedback
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while the previous execution is still in progress
    init<SubState>(feedback: @escaping (SubState) -> StreamMutation,
                   lensingOn lense: @escaping (StreamState.Value) -> SubState,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedback: (StreamState.Value) -> StreamMutation = { state -> StreamMutation in
            let substate = lense(state)
            return feedback(substate)
        }

        self.init(feedback: feedback, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Mutation> stream, dismissing the `SubState` values that don't match the filter
    /// - Parameters:
    ///   - feedback: the function transforming a `SubState` to a reactive stream of `Mutation`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type paased as an input to the feedback
    ///   - filter: the filter to apply to the input `State`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while the previous execution is still in progress
    init<SubState>(feedback: @escaping (SubState) -> StreamMutation,
                   lensingOn lense: @escaping (StreamState.Value) -> SubState,
                   filteredBy filter: @escaping (SubState) -> Bool,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedback: (StreamState.Value) -> StreamMutation = { state -> StreamMutation in
            let substate = lense(state)
            return feedback(substate)
        }

        let filterState: (StreamState.Value) -> Bool = { state -> Bool in
            return filter(lense(state))
        }

        self.init(feedback: feedback, filteredBy: filterState, on: executer, applying: strategy)
    }
}

@_functionBuilder
public struct FeedbackBuilder {
    public static func buildBlock<FeedbackType: Feedback>(_ feedback: FeedbackType) -> FeedbackType {
        return feedback
    }

    public static func buildBlock<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(_ feedbackA: FeedbackTypeA,
                                                                                    _ feedbackB: FeedbackTypeB) -> (FeedbackTypeA, FeedbackTypeB)
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation {
            return (feedbackA, feedbackB)
    }

    public static func buildBlock<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(_ feedbackA: FeedbackTypeA,
                                                                                                             _ feedbackB: FeedbackTypeB,
                                                                                                             _ feedbackC: FeedbackTypeC) -> (FeedbackTypeA, FeedbackTypeB, FeedbackTypeC)
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation {
            return (feedbackA, feedbackB, feedbackC)
    }

    public static func buildBlock<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback>(
        _ feedbackA: FeedbackTypeA,
        _ feedbackB: FeedbackTypeB,
        _ feedbackC: FeedbackTypeC,
        _ feedbackD: FeedbackTypeD) -> (FeedbackTypeA, FeedbackTypeB, FeedbackTypeC, FeedbackTypeD)
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation {
            return (feedbackA, feedbackB, feedbackC, feedbackD)
    }

    public static func buildBlock<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, FeedbackTypeE: Feedback>(
        _ feedbackA: FeedbackTypeA,
        _ feedbackB: FeedbackTypeB,
        _ feedbackC: FeedbackTypeC,
        _ feedbackD: FeedbackTypeD,
        _ feedbackE: FeedbackTypeE) -> (FeedbackTypeA, FeedbackTypeB, FeedbackTypeC, FeedbackTypeD, FeedbackTypeE)
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                FeedbackTypeD.StreamState == FeedbackTypeE.StreamState,
                FeedbackTypeD.StreamMutation == FeedbackTypeE.StreamMutation {
            return (feedbackA, feedbackB, feedbackC, feedbackD, feedbackE)
    }
}
