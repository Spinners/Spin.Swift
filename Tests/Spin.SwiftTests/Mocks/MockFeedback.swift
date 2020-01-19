//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift

struct MockFeedback<State: CanBeEmpty, Event: CanBeEmpty>: Feedback {
    typealias StateStream = MockStream<State>
    typealias EventStream = MockStream<Event>
    typealias Executer = MockExecuter

    var feedbackStream: (StateStream) -> EventStream
    var feedbackExecuter: Executer?

    init(feedback: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        self.feedbackStream = feedback
        self.feedbackExecuter = executer
    }

    init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where FeedbackType.StateStream == StateStream, FeedbackType.EventStream == EventStream {
        let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
            _ = feedbacks.map { $0.feedbackStream(stateStream) }
            return .emptyStream()
        }

        self.init(feedback: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

        let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            return .emptyStream()
        }

        self.init(feedback: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB, _ feedbackC: FeedbackTypeC)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeB.StateStream == FeedbackTypeC.StateStream,
                 FeedbackTypeB.EventStream == FeedbackTypeC.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

         let feedback: (StateStream) -> EventStream = { stateStream in
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
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeB.StateStream == FeedbackTypeC.StateStream,
                 FeedbackTypeB.EventStream == FeedbackTypeC.EventStream,
                 FeedbackTypeC.StateStream == FeedbackTypeD.StateStream,
                 FeedbackTypeC.EventStream == FeedbackTypeD.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

         let feedback: (StateStream) -> EventStream = { stateStream in
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
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeB.StateStream == FeedbackTypeC.StateStream,
                 FeedbackTypeB.EventStream == FeedbackTypeC.EventStream,
                 FeedbackTypeC.StateStream == FeedbackTypeD.StateStream,
                 FeedbackTypeC.EventStream == FeedbackTypeD.EventStream,
                 FeedbackTypeD.StateStream == FeedbackTypeE.StateStream,
                 FeedbackTypeD.EventStream == FeedbackTypeE.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

         let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)
            _ = feedbackD.feedbackStream(stateStream)
            _ = feedbackE.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    static func make(from effect: @escaping (StateStream.Value) -> EventStream, applying strategy: ExecutionStrategy) -> (StateStream) -> EventStream {
        let feedbackFromEffectStream: (StateStream) -> EventStream = { states in
            return states.flatMap(effect)
        }

        return feedbackFromEffectStream
    }
}
