//
//  Feedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// The strategy to apply when a new `State` value is given as input of a feedback while the previous execution is still
/// in progress
/// - continueOnNewEvent: the previous execution will go one while the new one is running
/// - cancelOnNewEvent: the previous execution will be canceled while the new one is starting
public enum ExecutionStrategy: Equatable {
    case continueOnNewEvent
    case cancelOnNewEvent
}

/// A feedback is basically a function transforming a reactive stream of `State` to a reactive stream of `Event`
/// while eventually performing side effects. The feedback can be executed on a dedicated `Executer`. If no `Executer`
/// is provided, then the feedback will be executer on the current `Executer`
public protocol Feedback {
    associatedtype StreamState: ReactiveStream
    associatedtype StreamEvent: ReactiveStream
    associatedtype Executer

    var feedbackStream: (StreamState) -> StreamEvent { get }

    static func make(from effect: @escaping (StreamState.Value) -> StreamEvent,
                     applying strategy: ExecutionStrategy) -> (StreamState) -> StreamEvent

    init(feedback: @escaping (StreamState) -> StreamEvent,
         on executer: Executer?)

    init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where   FeedbackType.StreamState == StreamState,
        FeedbackType.StreamEvent == StreamEvent

    init<FeedbackA, FeedbackB>(feedbacks feedbackA: FeedbackA,
                               _ feedbackB: FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent

    init<FeedbackA, FeedbackB, FeedbackC>(feedbacks feedbacksA: FeedbackA,
                                          _ feedbackB: FeedbackB,
                                          _ feedbackC: FeedbackC)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent

    init<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(feedbacks feedbackA: FeedbackA,
                                                     _ feedbackB: FeedbackB,
                                                     _ feedbackC: FeedbackC,
                                                     _ feedbackD: FeedbackD)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent

    init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(feedbacks feedbackA: FeedbackA,
                                                                _ feedbackB: FeedbackB,
                                                                _ feedbackC: FeedbackC,
                                                                _ feedbackD: FeedbackD,
                                                                _ feedbackE: FeedbackE)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackE: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackD.StreamState == FeedbackE.StreamState,
        FeedbackD.StreamEvent == FeedbackE.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent
}
