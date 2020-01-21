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
/// is provided, then the feedback will be executed on the current `Executer`
public protocol Feedback {
    associatedtype StateStream: ReactiveStream
    associatedtype EventStream: ReactiveStream
    associatedtype Executer

    var effect: (StateStream) -> EventStream { get }

    static func make(from effect: @escaping (StateStream.Value) -> EventStream,
                     applying strategy: ExecutionStrategy) -> (StateStream) -> EventStream

    init(effect: @escaping (StateStream) -> EventStream, on executer: Executer?)

    init<FeedbackType: Feedback>(feedbacks: [FeedbackType])
        where
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream

    init<FeedbackA, FeedbackB>(feedbacks feedbackA: FeedbackA,
                               _ feedbackB: FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream

    init<FeedbackA, FeedbackB, FeedbackC>(feedbacks feedbacksA: FeedbackA,
                                          _ feedbackB: FeedbackB,
                                          _ feedbackC: FeedbackC)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream

    init<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(feedbacks feedbackA: FeedbackA,
                                                     _ feedbackB: FeedbackB,
                                                     _ feedbackC: FeedbackC,
                                                     _ feedbackD: FeedbackD)
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
        FeedbackA.EventStream == EventStream

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
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream
}
