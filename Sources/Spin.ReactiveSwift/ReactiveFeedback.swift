//
//  ReactiveFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

public struct ReactiveFeedback<State, Event>: Feedback {
    public typealias StateStream = SignalProducer<State, Never>
    public typealias EventStream = SignalProducer<Event, Never>
    public typealias Executer = Scheduler

    public let effect: (StateStream) -> EventStream

    public init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.effect = effect
            return
        }

        self.effect = { stateStream in
            return effect(stateStream.observe(on: executer))
        }
    }

    public init<FeedbackType: Feedback>(feedbacks: [FeedbackType])
        where FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
                let eventStreams = feedbacks.map { $0.effect(stateStream) }
                return SignalProducer.merge(eventStreams)
            }

            self.init(effect: feedback)
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
                return SignalProducer.merge(feedbackA.effect(stateStream),
                                            feedbackB.effect(stateStream))
            }

            self.init(effect: feedback)
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
                return SignalProducer.merge(feedbackA.effect(stateStream),
                                            feedbackB.effect(stateStream),
                                            feedbackC.effect(stateStream))
            }

            self.init(effect: feedback)
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
                return SignalProducer.merge(feedbackA.effect(stateStream),
                                            feedbackB.effect(stateStream),
                                            feedbackC.effect(stateStream),
                                            feedbackD.effect(stateStream))
            }

            self.init(effect: feedback)
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
                return SignalProducer.merge(feedbackA.effect(stateStream),
                                            feedbackB.effect(stateStream),
                                            feedbackC.effect(stateStream),
                                            feedbackD.effect(stateStream),
                                            feedbackE.effect(stateStream))
            }

            self.init(effect: feedback)
    }

    public static func make(from effect: @escaping (StateStream.Value) -> EventStream,
                            applying strategy: ExecutionStrategy) -> (StateStream) -> EventStream {
        let feedbackFromEffectStream: (StateStream) -> EventStream = { states in
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
