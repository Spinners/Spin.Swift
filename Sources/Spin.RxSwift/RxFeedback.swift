//
//  RxFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import Spin_Swift

public struct RxFeedback<State, Mutation>: Feedback {
    public typealias StreamState = Observable<State>
    public typealias StreamMutation = Observable<Mutation>
    public typealias Executer = ImmediateSchedulerType

    public let feedbackStream: (StreamState) -> StreamMutation
    public var feedbackExecuter: Executer?

    public init(feedback: @escaping (StreamState) -> StreamMutation, on executer: Executer? = nil) {
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
        FeedbackType.StreamState == StreamState,
        FeedbackType.StreamMutation == StreamMutation {
        let feedback = { (stateStream: FeedbackType.StreamState) -> FeedbackType.StreamMutation in
            let mutationStreams = feedbacks.map { $0.feedbackStream(stateStream) }
            return Observable.merge(mutationStreams)
        }

        self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB>(feedbacks feedbackA: FeedbackA, _ feedbackB: FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamMutation == FeedbackB.StreamMutation,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamMutation == StreamMutation {
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
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamMutation == FeedbackB.StreamMutation,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamMutation == FeedbackC.StreamMutation,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamMutation == StreamMutation {
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
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamMutation == FeedbackB.StreamMutation,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamMutation == FeedbackC.StreamMutation,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamMutation == FeedbackD.StreamMutation,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamMutation == StreamMutation {
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
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamMutation == FeedbackB.StreamMutation,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamMutation == FeedbackC.StreamMutation,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamMutation == FeedbackD.StreamMutation,
        FeedbackD.StreamState == FeedbackE.StreamState,
        FeedbackD.StreamMutation == FeedbackE.StreamMutation,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamMutation == StreamMutation {
        let feedback = { stateStream in
            return Observable.merge(feedbackA.feedbackStream(stateStream),
                                    feedbackB.feedbackStream(stateStream),
                                    feedbackC.feedbackStream(stateStream),
                                    feedbackD.feedbackStream(stateStream),
                                    feedbackE.feedbackStream(stateStream))
        }

        self.init(feedback: feedback)
    }

    public static func make(from effect: @escaping (StreamState.Value) -> StreamMutation,
                            applying strategy: ExecutionStrategy) -> (StreamState) -> StreamMutation {
        let effectStream = { (state: StreamState.Value) -> StreamMutation in
            return effect(state).catchError { _ in return .empty() }
        }

        let feedbackFromEffectStream: (StreamState) -> StreamMutation = { states in
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
