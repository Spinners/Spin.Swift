//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift

struct MockFeedback<State: CanBeEmpty, Event: CanBeEmpty>: Feedback {
    typealias StreamState = MockStream<State>
    typealias StreamEvent = MockStream<Event>
    typealias Executer = MockExecuter

    var feedbackStream: (StreamState) -> StreamEvent
    var feedbackExecuter: Executer?

    init(feedback: @escaping (StreamState) -> StreamEvent, on executer: Executer? = nil) {
        self.feedbackStream = feedback
        self.feedbackExecuter = executer
    }

    init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where FeedbackType.StreamState == StreamState, FeedbackType.StreamEvent == StreamEvent {
        let feedback = { (stateStream: FeedbackType.StreamState) -> FeedbackType.StreamEvent in
            _ = feedbacks.map { $0.feedbackStream(stateStream) }
            return .emptyStream()
        }

        self.init(feedback: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamEvent == FeedbackTypeB.StreamEvent,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamEvent == StreamEvent {

        let feedback: (StreamState) -> StreamEvent = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            return .emptyStream()
        }

        self.init(feedback: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB, _ feedbackC: FeedbackTypeC)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamEvent == FeedbackTypeB.StreamEvent,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamEvent == FeedbackTypeC.StreamEvent,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamEvent == StreamEvent {

         let feedback: (StreamState) -> StreamEvent = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback>(feedbacks feedbackA: FeedbackTypeA,
                                                                                                                     _ feedbackB: FeedbackTypeB,
                                                                                                                     _ feedbackC: FeedbackTypeC,
                                                                                                                     _ feedbackD: FeedbackTypeD)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamEvent == FeedbackTypeB.StreamEvent,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamEvent == FeedbackTypeC.StreamEvent,
                 FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                 FeedbackTypeC.StreamEvent == FeedbackTypeD.StreamEvent,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamEvent == StreamEvent {

         let feedback: (StreamState) -> StreamEvent = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)
            _ = feedbackD.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, FeedbackTypeE: Feedback>(feedbacks feedbackA: FeedbackTypeA,
                                                                                                                                              _ feedbackB: FeedbackTypeB,
                                                                                                                                              _ feedbackC: FeedbackTypeC,
                                                                                                                                              _ feedbackD: FeedbackTypeD,
                                                                                                                                              _ feedbackE: FeedbackTypeE)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamEvent == FeedbackTypeB.StreamEvent,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamEvent == FeedbackTypeC.StreamEvent,
                 FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                 FeedbackTypeC.StreamEvent == FeedbackTypeD.StreamEvent,
                 FeedbackTypeD.StreamState == FeedbackTypeE.StreamState,
                 FeedbackTypeD.StreamEvent == FeedbackTypeE.StreamEvent,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamEvent == StreamEvent {

         let feedback: (StreamState) -> StreamEvent = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)
            _ = feedbackD.feedbackStream(stateStream)
            _ = feedbackE.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    static func make(from effect: @escaping (StreamState.Value) -> StreamEvent, applying strategy: ExecutionStrategy) -> (StreamState) -> StreamEvent {
        let feedbackFromEffectStream: (StreamState) -> StreamEvent = { states in
            return states.flatMap(effect)
        }

        return feedbackFromEffectStream
    }
}
