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

    public let effect: (StateStream) -> EventStream
    public var feedbackExecuter: Executer?

    public init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.effect = effect
            return
        }

        self.effect = { stateStream in
            return effect(stateStream.observeOn(executer))
        }
    }


    public init(effect: @escaping (StateStream.Value) -> EventStream,
                on executer: Executer? = nil,
                applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectStream = { (state: StateStream.Value) -> EventStream in
            return effect(state).catchError { _ in return .empty() }
        }

        let fullEffect: (StateStream) -> EventStream = { states in
            switch strategy {
            case .continueOnNewEvent:
                return states.flatMap(effectStream)
            case .cancelOnNewEvent:
                return states.flatMapLatest(effectStream)
            }
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init(directEffect: @escaping (StateStream.Value) -> EventStream.Value, on executer: Executer? = nil) {
        let fullEffect: (StateStream) -> EventStream = { states in
            return states.map(directEffect)
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init<FeedbackType: Feedback>(feedbacks: [FeedbackType])
        where
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
        let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
            let eventStreams = feedbacks.map { $0.effect(stateStream) }
            return Observable.merge(eventStreams)
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
            return Observable.merge(feedbackA.effect(stateStream),
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
            return Observable.merge(feedbackA.effect(stateStream),
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
            return Observable.merge(feedbackA.effect(stateStream),
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
            return Observable.merge(feedbackA.effect(stateStream),
                                    feedbackB.effect(stateStream),
                                    feedbackC.effect(stateStream),
                                    feedbackD.effect(stateStream),
                                    feedbackE.effect(stateStream))
        }

        self.init(effect: feedback)
    }
}
