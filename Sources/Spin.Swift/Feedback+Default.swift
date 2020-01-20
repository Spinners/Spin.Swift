//
//  Feedback+Default.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

public enum FeedbackFilterError: Error {
    case effectIsNotExecuted
}

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

    init<StateStreamType, EventStreamType>(_ feedbackStreams: [(StateStream) -> EventStream])
        where
        StateStreamType == StateStream,
        EventStreamType == EventStream {
            let feedbacks = feedbackStreams.map { Self(feedback: $0, on: nil) }
            self.init(feedbacks: feedbacks)
    }

    init<FeedbackType>(_ feedback: FeedbackType)
        where
        FeedbackType: Feedback,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream,
        FeedbackType.Executer == Executer {
            self.init(feedback: feedback.feedbackStream, on: nil)
    }

    init<FeedbackType>(@FeedbackBuilder builder: () -> FeedbackType)
        where
        FeedbackType: Feedback,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            let feedback = builder()
            self.init(feedback: feedback.feedbackStream, on: nil)
    }

    init<FeedbackA, FeedbackB>(@FeedbackBuilder builder: () -> (FeedbackA, FeedbackB))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            self.init(feedbacks: feedbackA, feedbackB)
    }

    init<FeedbackA, FeedbackB, FeedbackC>(@FeedbackBuilder builder: () -> (FeedbackA, FeedbackB, FeedbackC))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            let feedbackC = feedbacks.2
            self.init(feedbacks: feedbackA, feedbackB, feedbackC)
    }

    init<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(@FeedbackBuilder builder: () -> (  FeedbackA,
                                                                                        FeedbackB,
                                                                                        FeedbackC,
                                                                                        FeedbackD))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            let feedbackC = feedbacks.2
            let feedbackD = feedbacks.3
            self.init(feedbacks: feedbackA, feedbackB, feedbackC, feedbackD)
    }

    init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(@FeedbackBuilder builder: () -> (   FeedbackA,
                                                                                                    FeedbackB,
                                                                                                    FeedbackC,
                                                                                                    FeedbackD,
                                                                                                    FeedbackE))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackE: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let feedbacks = builder()
            let feedbackA = feedbacks.0
            let feedbackB = feedbacks.1
            let feedbackC = feedbacks.2
            let feedbackD = feedbacks.3
            let feedbackE = feedbacks.4
            self.init(feedbacks: feedbackA, feedbackB, feedbackC, feedbackD, feedbackE)
    }

    /// Initialize the feedback with a: State -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - feedback: the function transforming a `State` to a reactive stream of `Event`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init(feedback: @escaping (StateStream.Value) -> EventStream,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedbackStreamFromEffect = Self.make(from: feedback, applying: strategy)
        self.init(feedback: feedbackStreamFromEffect, on: executer)
    }

    /// Initialize the feedback with a: State -> ReactiveStream<Event> stream, dismissing the `State` values that
    /// don't match the filter
    /// - Parameters:
    ///   - feedback: the function transforming a `State` to a reactive stream of `Event`
    ///   - filter: the filter to apply to the input `State`.
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init(feedback: @escaping (StateStream.Value) -> EventStream,
         filteredBy filter: @escaping (StateStream.Value) -> Bool,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedbackFromStateValueWithFilter: (StateStream.Value) -> EventStream = { state -> EventStream in
            guard filter(state) else {
                return EventStream.emptyStream()
            }

            return feedback(state)
        }

        self.init(feedback: feedbackFromStateValueWithFilter, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: SubState -> ReactiveStream<Event> stream, dismissing the `State` values that
    /// don't match the filter.
    /// The returned Result allows to extract a SubState from the State and to pass it to the feedback function
    /// - Parameters:
    ///   - feedback: the function transforming a `State` to a reactive stream of `Event`
    ///   - filter: the filter to apply to the input `State`. It should return .success(value) in case the feedabck should be executed
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(feedback: @escaping (SubState) -> EventStream,
         filteredByResult filter: @escaping (StateStream.Value) -> Result<SubState, FeedbackFilterError>,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedbackFromStateValueWithFilter: (StateStream.Value) -> EventStream = { state -> EventStream in
            guard case let .success(substate) = filter(state) else {
                return EventStream.emptyStream()
            }

            return feedback(substate)
        }

        self.init(feedback: feedbackFromStateValueWithFilter, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: State -> Void stream
    /// - Parameters:
    ///   - feedback: the function transforming a `State` to a Void output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(feedback: @escaping (StateStream.Value) -> Void, on executer: Executer? = nil) {
        let feedbackFromStateValue: (StateStream.Value) -> EventStream = { state -> EventStream in
            feedback(state)
            return EventStream.emptyStream()
        }

        self.init(feedback: feedbackFromStateValue, on: executer, applying: Self.defaultExecutionStrategy)
    }

    /// Initialize the feedback with a: Void -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - feedback: the function transforming a Void input to a ReactiveStream<Event> output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(feedback: @escaping () -> EventStream, on executer: Executer? = nil) {
        let feedbackFromStateStream: (StateStream) -> EventStream = { _ -> EventStream in
            return feedback()
        }

        self.init(feedback: feedbackFromStateStream, on: executer)
    }

    /// Initialize the feedback with 2 partial feedbacks. Those 2 partial feedbacks will be concatenated to become a
    /// complete ReactiveStream<State> -> ReactiveStream<Event> feedback
    /// - Parameters:
    ///   - stateInterpret: the function transforming a `State` to a Void output
    ///   - eventEmitter: the function transforming a Void input to a ReactiveStream<Event> output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(uiFeedbacks stateInterpret: @escaping (StateStream.Value) -> Void,
         _ eventEmitter: @escaping () -> EventStream, on executer: Executer? = nil) {
        let stateFeedback = Self(feedback: stateInterpret, on: executer)
        let eventFeedback = Self(feedback: eventEmitter, on: executer)

        self.init(feedbacks: stateFeedback, eventFeedback)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - feedback: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type paased as an input to the feedback
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(feedback: @escaping (SubState) -> EventStream,
                   lensingOn lense: @escaping (StateStream.Value) -> SubState,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedback: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = lense(state)
            return feedback(substate)
        }

        self.init(feedback: feedback, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream, dismissing the `SubState` values
    /// that don't match the filter
    /// - Parameters:
    ///   - feedback: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type paased as an input to the feedback
    ///   - filter: the filter to apply to the input `State`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(feedback: @escaping (SubState) -> EventStream,
                   lensingOn lense: @escaping (StateStream.Value) -> SubState,
                   filteredBy filter: @escaping (SubState) -> Bool,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let feedback: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = lense(state)
            return feedback(substate)
        }

        let filterState: (StateStream.Value) -> Bool = { state -> Bool in
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

    public static func buildBlock<FeedbackA, FeedbackB>(_ feedbackA: FeedbackA,
                                                        _ feedbackB: FeedbackB) -> (FeedbackA, FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream {
            return (feedbackA, feedbackB)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC>(_ feedbackA: FeedbackA,
                                                                   _ feedbackB: FeedbackB,
                                                                   _ feedbackC: FeedbackC) -> ( FeedbackA,
                                                                                                FeedbackB,
                                                                                                FeedbackC)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream {
            return (feedbackA, feedbackB, feedbackC)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(_ feedbackA: FeedbackA,
                                                                              _ feedbackB: FeedbackB,
                                                                              _ feedbackC: FeedbackC,
                                                                              _ feedbackD: FeedbackD) -> (  FeedbackA,
                                                                                                            FeedbackB,
                                                                                                            FeedbackC,
                                                                                                            FeedbackD)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream {
            return (feedbackA, feedbackB, feedbackC, feedbackD)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(_ feedbackA: FeedbackA,
                                                                                         _ feedbackB: FeedbackB,
                                                                                         _ feedbackC: FeedbackC,
                                                                                         _ feedbackD: FeedbackD,
                                                                                         _ feedbackE: FeedbackE)
        -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackE: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream {
            return (feedbackA, feedbackB, feedbackC, feedbackD, feedbackE)
    }
}
