//
//  Feedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// The strategy to apply when a new `State` value is given as input of a feedback while the previous execution is still in progress
/// - continueOnNewEvent: the previous execution will go one while the new one is running
/// - cancelOnNewEvent: the previous execution will be canceled while the new one is starting
public enum ExecutionStrategy: Equatable {
    case continueOnNewEvent
    case cancelOnNewEvent
}

/// A feedback is basically a function transforming a reactive stream of `State` to a reactive stream of `Mutation` while eventually performing side effects
/// The feedback can be executed on a dedicated `Executer`. If no `Executer` is provided, then the feedback will be executer on the current `Executer`
public protocol Feedback {
    associatedtype StreamState: ReactiveStream
    associatedtype StreamMutation: ReactiveStream
    associatedtype Executer

    var feedbackStream: (StreamState) -> StreamMutation { get }
    static func make(from effect: @escaping (StreamState.Value) -> StreamMutation, applying strategy: ExecutionStrategy) -> (StreamState) -> StreamMutation

    init(feedback: @escaping (StreamState) -> StreamMutation, on executer: Executer?)

    init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where FeedbackType.StreamState == StreamState, FeedbackType.StreamMutation == StreamMutation

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB)
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeA.StreamState == StreamState,
                FeedbackTypeA.StreamMutation == StreamMutation

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(feedbacks feedbacksA: FeedbackTypeA, _ feedbackB: FeedbackTypeB, _ feedbackC: FeedbackTypeC)
        where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeA.StreamState == StreamState,
                FeedbackTypeA.StreamMutation == StreamMutation

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback>(feedbacks feedbackA: FeedbackTypeA,
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
                FeedbackTypeA.StreamMutation == StreamMutation

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, FeedbackTypeE: Feedback>(feedbacks feedbackA: FeedbackTypeA,
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
                FeedbackTypeA.StreamMutation == StreamMutation
}
