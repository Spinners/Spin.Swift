//
//  RxFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import Spin_Swift

public struct RxFeedback<State, Event>: Feedback {
    public typealias StateStream = Observable<State>
    public typealias EventStream = Observable<Event>
    public typealias Executer = ImmediateSchedulerType

    public let feedbackStream: (StateStream) -> EventStream
    public var feedbackExecuter: Executer?

    public init(feedback: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.feedbackStream = feedback
            return
        }

        self.feedbackStream = { stateStream in
            return feedback(stateStream.observeOn(executer))
        }
    }

    public init<FeedbackType: Feedback>(feedbacks: [FeedbackType])
        where
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
        let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
            let eventStreams = feedbacks.map { $0.feedbackStream(stateStream) }
            return Observable.merge(eventStreams)
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB>(feedbacks feedbackA: FeedbackA, _ feedbackB: FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB, FeedbackC>(feedbacks feedbackA: FeedbackA,
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
        FeedbackA.EventStream == EventStream {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream),
                                    feedbackC.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(feedbacks feedbackA: FeedbackA,
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
        FeedbackA.EventStream == EventStream {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream),
                                    feedbackC.feedbackStream(stateStream),
                                    feedbackD.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(feedbacks feedbackA: FeedbackA,
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
        FeedbackA.EventStream == EventStream {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream),
                                    feedbackC.feedbackStream(stateStream),
                                    feedbackD.feedbackStream(stateStream),
                                    feedbackE.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public static func make(from effect: @escaping (StateStream.Value) -> EventStream,
                            applying strategy: ExecutionStrategy) -> (StateStream) -> EventStream {
        let effectStream = { (state: StateStream.Value) -> EventStream in
            return effect(state).catchError { _ in return .empty() }
        }

        let feedbackFromEffectStream: (StateStream) -> EventStream = { states in
            switch strategy {
            case .continueOnNewEvent:
                return states.flatMap(effectStream)
            case .cancelOnNewEvent:
                return states.flatMapLatest(effectStream)
            }
        }

        return feedbackFromEffectStream
    }
}
