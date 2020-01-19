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

    public let feedbackStream: (StateStream) -> EventStream

    public init(feedback: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.feedbackStream = feedback
            return
        }

        self.feedbackStream = { stateStream in
            return feedback(stateStream.receive(on: executer).eraseToAnyPublisher()).eraseToAnyPublisher()
        }
    }

    public init<FeedbackType>(feedbacks: [FeedbackType])
        where
        FeedbackType: Feedback,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
                let eventStreams = feedbacks.map { $0.feedbackStream(stateStream) }
                return Publishers.MergeMany(eventStreams).eraseToAnyPublisher()
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
                return Publishers.Merge(feedbackA.feedbackStream(stateStream),
                                        feedbackB.feedbackStream(stateStream))
                    .eraseToAnyPublisher()
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
                return Publishers.Merge3(feedbackA.feedbackStream(stateStream),
                                         feedbackB.feedbackStream(stateStream),
                                         feedbackC.feedbackStream(stateStream))
                    .eraseToAnyPublisher()
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
                return Publishers.Merge4(feedbackA.feedbackStream(stateStream),
                                         feedbackB.feedbackStream(stateStream),
                                         feedbackC.feedbackStream(stateStream),
                                         feedbackD.feedbackStream(stateStream))
                    .eraseToAnyPublisher()
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
                return Publishers.Merge5(feedbackA.feedbackStream(stateStream),
                                         feedbackB.feedbackStream(stateStream),
                                         feedbackC.feedbackStream(stateStream),
                                         feedbackD.feedbackStream(stateStream),
                                         feedbackE.feedbackStream(stateStream))
                    .eraseToAnyPublisher()
            }

            self.init(feedback: feedback)
    }

    public static func make(from effect: @escaping (StateStream.Value) -> EventStream,
                            applying strategy: ExecutionStrategy) -> (StateStream) -> EventStream {
        let feedbackFromEffectStream: (StateStream) -> EventStream = { states in
            switch strategy {
            case .continueOnNewEvent:
                return states.flatMap(effect).eraseToAnyPublisher()
            case .cancelOnNewEvent:
                return states.map(effect).switchToLatest().eraseToAnyPublisher()
            }
        }

        return feedbackFromEffectStream
    }
}

public typealias DispatchQueueCombineFeedback<State, Event> =
    CombineFeedback<State, Event, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>
