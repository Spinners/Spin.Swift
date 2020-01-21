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
        let newFeedback = Self(effect: self.effect, on: executer)
        return newFeedback
    }

    init<StateStreamType, EventStreamType>(_ effects: [(StateStream) -> EventStream])
        where
        StateStreamType == StateStream,
        EventStreamType == EventStream {
            let feedbacks = effects.map { Self(effect: $0, on: nil) }
            self.init(feedbacks: feedbacks)
    }

    init<FeedbackType>(_ feedback: FeedbackType)
        where
        FeedbackType: Feedback,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream,
        FeedbackType.Executer == Executer {
            self.init(effect: feedback.effect, on: nil)
    }

    init<FeedbackType>(@FeedbackBuilder builder: () -> FeedbackType)
        where
        FeedbackType: Feedback,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            let feedback = builder()
            self.init(effect: feedback.effect, on: nil)
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
    ///   - effect: the function transforming a `State` to a reactive stream of `Event`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init(effect: @escaping (StateStream.Value) -> EventStream,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effect = Self.make(from: effect, applying: strategy)
        self.init(effect: effect, on: executer)
    }

    init(directEffect: @escaping (StateStream.Value) -> EventStream.Value,
         on executer: Executer? = nil) {
        let effect = Self.make(from: directEffect)
        self.init(effect: effect, on: executer)
    }

    /// Initialize the feedback with a: State -> ReactiveStream<Event> stream, dismissing the `State` values that
    /// don't match the filter
    /// - Parameters:
    ///   - effect: the function transforming a `State` to a reactive stream of `Event`
    ///   - filter: the filter to apply to the input `State`.
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init(effect: @escaping (StateStream.Value) -> EventStream,
         filteredBy filter: @escaping (StateStream.Value) -> Bool,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectWithFilter: (StateStream.Value) -> EventStream = { state -> EventStream in
            guard filter(state) else {
                return EventStream.emptyStream()
            }

            return effect(state)
        }

        self.init(effect: effectWithFilter, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: SubState -> ReactiveStream<Event> stream, dismissing the `State` values that
    /// don't match the filter.
    /// The returned Result allows to extract a SubState from the State and to pass it to the feedback function
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - filter: the filter to apply to the input `State`. It should return .success(value) in case the feedabck should be executed
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   filteredByResult filter: @escaping (StateStream.Value) -> Result<SubState, FeedbackFilterError>,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectWithFilter: (StateStream.Value) -> EventStream = { state -> EventStream in
            guard case let .success(substate) = filter(state) else {
                return EventStream.emptyStream()
            }

            return effect(substate)
        }

        self.init(effect: effectWithFilter, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: State -> Void stream
    /// - Parameters:
    ///   - effect: the function transforming a `State` to a Void output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(effect: @escaping (StateStream.Value) -> Void, on executer: Executer? = nil) {
        let effectFromStateValue: (StateStream.Value) -> EventStream = { state -> EventStream in
            effect(state)
            return EventStream.emptyStream()
        }

        self.init(effect: effectFromStateValue, on: executer, applying: Self.defaultExecutionStrategy)
    }

    /// Initialize the feedback with a: Void -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - effect: the function transforming a Void input to a ReactiveStream<Event> output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(effect: @escaping () -> EventStream, on executer: Executer? = nil) {
        let effectFromEventStream: (StateStream) -> EventStream = { _ -> EventStream in
            return effect()
        }

        self.init(effect: effectFromEventStream, on: executer)
    }

    /// Initialize the feedback with 2 partial feedbacks. Those 2 partial feedbacks will be concatenated to become a
    /// complete ReactiveStream<State> -> ReactiveStream<Event> feedback
    /// - Parameters:
    ///   - stateInterpret: the function transforming a `State` to a Void output
    ///   - eventEmitter: the function transforming a Void input to a ReactiveStream<Event> output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(uiEffects stateInterpret: @escaping (StateStream.Value) -> Void,
         _ eventEmitter: @escaping () -> EventStream, on executer: Executer? = nil) {
        let stateFeedback = Self(effect: stateInterpret, on: executer)
        let eventFeedback = Self(effect: eventEmitter, on: executer)

        self.init(feedbacks: stateFeedback, eventFeedback)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type paased as an input to the feedback
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   lensingOn lense: @escaping (StateStream.Value) -> SubState,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectFromSubState: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = lense(state)
            return effect(substate)
        }

        self.init(effect: effectFromSubState, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream, dismissing the `SubState` values
    /// that don't match the filter
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type paased as an input to the feedback
    ///   - filter: the filter to apply to the input `State`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   lensingOn lense: @escaping (StateStream.Value) -> SubState,
                   filteredBy filter: @escaping (SubState) -> Bool,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectFromSubState: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = lense(state)
            return effect(substate)
        }

        let filterState: (StateStream.Value) -> Bool = { state -> Bool in
            return filter(lense(state))
        }

        self.init(effect: effectFromSubState, filteredBy: filterState, on: executer, applying: strategy)
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
