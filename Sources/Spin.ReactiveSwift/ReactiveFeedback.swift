//
//  ReactiveFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

public struct ReactiveFeedback<State, Mutation>: Feedback {
    public typealias StreamState = SignalProducer<State, Never>
    public typealias StreamMutation = SignalProducer<Mutation, Never>
    public typealias Executer = Scheduler

    public let feedbackStream: (StreamState) -> StreamMutation

    public init(feedback: @escaping (StreamState) -> StreamMutation, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.feedbackStream = feedback
            return
        }

        self.feedbackStream = { stateStream in
            return feedback(stateStream.observe(on: executer))
        }
    }

    public init<FeedbackType: Feedback>(feedbacks: [FeedbackType])
        where FeedbackType.StreamState == StreamState,
        FeedbackType.StreamMutation == StreamMutation {
            let feedback = { (stateStream: FeedbackType.StreamState) -> FeedbackType.StreamMutation in
                let mutationStreams = feedbacks.map { $0.feedbackStream(stateStream) }
                return SignalProducer.merge(mutationStreams)
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
                return SignalProducer.merge(feedbackA.feedbackStream(stateStream),
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
                return SignalProducer.merge(feedbackA.feedbackStream(stateStream),
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
                return SignalProducer.merge(feedbackA.feedbackStream(stateStream),
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
                return SignalProducer.merge(feedbackA.feedbackStream(stateStream),
                                            feedbackB.feedbackStream(stateStream),
                                            feedbackC.feedbackStream(stateStream),
                                            feedbackD.feedbackStream(stateStream),
                                            feedbackE.feedbackStream(stateStream))
            }

            self.init(feedback: feedback)
    }

    public static func make(from effect: @escaping (StreamState.Value) -> StreamMutation,
                            applying strategy: ExecutionStrategy) -> (StreamState) -> StreamMutation {
        let feedbackFromEffectStream: (StreamState) -> StreamMutation = { states in
            switch strategy {
            case .continueOnNewEvent:
                return states.flatMap(.merge, effect)
            case .cancelOnNewEvent:
                return states.flatMap(.latest, effect)
            }
        }

        return feedbackFromEffectStream
    }
}
