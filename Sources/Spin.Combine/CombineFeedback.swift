//
//  CombineFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import Spin_Swift

public struct CombineFeedback<State, Event, SchedulerTime, SchedulerOptions>: Feedback
    where SchedulerTime: Strideable, SchedulerTime.Stride: SchedulerTimeIntervalConvertible {
    public typealias StateStream = AnyPublisher<State, Never>
    public typealias EventStream = AnyPublisher<Event, Never>
    public typealias Executer = AnyScheduler<SchedulerTime, SchedulerOptions>

    public let effect: (StateStream) -> EventStream

    public init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.effect = effect
            return
        }

        self.effect = { stateStream in
            return effect(stateStream.receive(on: executer).eraseToAnyPublisher()).eraseToAnyPublisher()
        }
    }

    public init(effect: @escaping (StateStream.Value) -> EventStream,
                on executer: Executer? = nil,
                applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let fullEffect: (StateStream) -> EventStream = { states in
            switch strategy {
            case .continueOnNewEvent:
                return states.flatMap(effect).eraseToAnyPublisher()
            case .cancelOnNewEvent:
                return states.map(effect).switchToLatest().eraseToAnyPublisher()
            }
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init(directEffect: @escaping (StateStream.Value) -> EventStream.Value, on executer: Executer? = nil) {
        let fullEffect: (StateStream) -> EventStream = { states in
            return states.map(directEffect).eraseToAnyPublisher()
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init<FeedbackType>(feedbacks: [FeedbackType])
        where
        FeedbackType: Feedback,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
                let eventStreams = feedbacks.map { $0.effect(stateStream) }
                return Publishers.MergeMany(eventStreams).eraseToAnyPublisher()
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
                return Publishers.Merge(feedbackA.effect(stateStream),
                                        feedbackB.effect(stateStream))
                    .eraseToAnyPublisher()
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
                return Publishers.Merge3(feedbackA.effect(stateStream),
                                         feedbackB.effect(stateStream),
                                         feedbackC.effect(stateStream))
                    .eraseToAnyPublisher()
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
                return Publishers.Merge4(feedbackA.effect(stateStream),
                                         feedbackB.effect(stateStream),
                                         feedbackC.effect(stateStream),
                                         feedbackD.effect(stateStream))
                    .eraseToAnyPublisher()
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
                return Publishers.Merge5(feedbackA.effect(stateStream),
                                         feedbackB.effect(stateStream),
                                         feedbackC.effect(stateStream),
                                         feedbackD.effect(stateStream),
                                         feedbackE.effect(stateStream))
                    .eraseToAnyPublisher()
            }

            self.init(effect: feedback)
    }
}

public typealias DispatchQueueCombineFeedback<State, Event> =
    CombineFeedback<State, Event, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>
