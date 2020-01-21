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

    var effect: (StateStream) -> EventStream
    var feedbackExecuter: Executer?

    init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        self.effect = effect
        self.feedbackExecuter = executer
    }

    init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where FeedbackType.StateStream == StateStream, FeedbackType.EventStream == EventStream {
        let feedback = { (stateStream: FeedbackType.StateStream) -> FeedbackType.EventStream in
            _ = feedbacks.map { $0.effect(stateStream) }
            return .emptyStream()
        }

        self.init(effect: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

        let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            return .emptyStream()
        }

        self.init(effect: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB, _ feedbackC: FeedbackTypeC)
         where   FeedbackTypeA.StateStream == FeedbackTypeB.StateStream,
                 FeedbackTypeA.EventStream == FeedbackTypeB.EventStream,
                 FeedbackTypeB.StateStream == FeedbackTypeC.StateStream,
                 FeedbackTypeB.EventStream == FeedbackTypeC.EventStream,
                 FeedbackTypeA.StateStream == StateStream,
                 FeedbackTypeA.EventStream == EventStream {

         let feedback: (StateStream) -> EventStream = { stateStream in
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            _ = feedbackC.effect(stateStream)

            return .emptyStream()
         }

         self.init(effect: feedback)
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
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            _ = feedbackC.effect(stateStream)
            _ = feedbackD.effect(stateStream)

            return .emptyStream()
         }

         self.init(effect: feedback)
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
            _ = feedbackA.effect(stateStream)
            _ = feedbackB.effect(stateStream)
            _ = feedbackC.effect(stateStream)
            _ = feedbackD.effect(stateStream)
            _ = feedbackE.effect(stateStream)

            return .emptyStream()
         }

         self.init(effect: feedback)
     }

    static func make(from effect: @escaping (StateStream.Value) -> EventStream, applying strategy: ExecutionStrategy) -> (StateStream) -> EventStream {
        let feedbackFromEffectStream: (StateStream) -> EventStream = { states in
            return states.flatMap(effect)
        }

        return feedbackFromEffectStream
    }
}
