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
    public typealias StreamState = AnyPublisher<State, Never>
    public typealias StreamEvent = AnyPublisher<Event, Never>
    public typealias Executer = AnyScheduler<SchedulerTime, SchedulerOptions>

    public let feedbackStream: (StreamState) -> StreamEvent

    public init(feedback: @escaping (StreamState) -> StreamEvent, on executer: Executer? = nil) {
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
        FeedbackType.StreamState == StreamState,
        FeedbackType.StreamEvent == StreamEvent {
            let feedback = { (stateStream: FeedbackType.StreamState) -> FeedbackType.StreamEvent in
                let eventStreams = feedbacks.map { $0.feedbackStream(stateStream) }
                return Publishers.MergeMany(eventStreams).eraseToAnyPublisher()
            }

            self.init(feedback: feedback)
    }

    public init<FeedbackA, FeedbackB>(feedbacks feedbackA: FeedbackA, _ feedbackB: FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
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
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
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
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
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
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackD.StreamState == FeedbackE.StreamState,
        FeedbackD.StreamEvent == FeedbackE.StreamEvent,
        FeedbackA.StreamState == StreamState,
        FeedbackA.StreamEvent == StreamEvent {
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

    public static func make(from effect: @escaping (StreamState.Value) -> StreamEvent,
                            applying strategy: ExecutionStrategy) -> (StreamState) -> StreamEvent {
        let feedbackFromEffectStream: (StreamState) -> StreamEvent = { states in
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
