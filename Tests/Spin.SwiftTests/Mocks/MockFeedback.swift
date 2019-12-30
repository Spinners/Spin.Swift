//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift

struct MockFeedback<State: CanBeEmpty, Mutation: CanBeEmpty>: Feedback {
    typealias StreamState = MockStream<State>
    typealias StreamMutation = MockStream<Mutation>
    typealias Executer = MockExecuter

    var feedbackStream: (StreamState) -> StreamMutation
    var feedbackExecuter: Executer?

    init(feedback: @escaping (StreamState) -> StreamMutation, on executer: Executer? = nil) {
        self.feedbackStream = feedback
        self.feedbackExecuter = executer
    }

    init<FeedbackType: Feedback>(feedbacks: [FeedbackType]) where FeedbackType.StreamState == StreamState, FeedbackType.StreamMutation == StreamMutation {
        let feedback = { (stateStream: FeedbackType.StreamState) -> FeedbackType.StreamMutation in
            _ = feedbacks.map { $0.feedbackStream(stateStream) }
            return .emptyStream()
        }

        self.init(feedback: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

        let feedback: (StreamState) -> StreamMutation = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            return .emptyStream()
        }

        self.init(feedback: feedback)
    }

    init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback>(feedbacks feedbackA: FeedbackTypeA, _ feedbackB: FeedbackTypeB, _ feedbackC: FeedbackTypeC)
         where   FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

         let feedback: (StreamState) -> StreamMutation = { stateStream in
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
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                 FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                 FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

         let feedback: (StreamState) -> StreamMutation = { stateStream in
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
                 FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                 FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                 FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                 FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                 FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                 FeedbackTypeD.StreamState == FeedbackTypeE.StreamState,
                 FeedbackTypeD.StreamMutation == FeedbackTypeE.StreamMutation,
                 FeedbackTypeA.StreamState == StreamState,
                 FeedbackTypeA.StreamMutation == StreamMutation {

         let feedback: (StreamState) -> StreamMutation = { stateStream in
            _ = feedbackA.feedbackStream(stateStream)
            _ = feedbackB.feedbackStream(stateStream)
            _ = feedbackC.feedbackStream(stateStream)
            _ = feedbackD.feedbackStream(stateStream)
            _ = feedbackE.feedbackStream(stateStream)

            return .emptyStream()
         }

         self.init(feedback: feedback)
     }

    static func make(from effect: @escaping (StreamState.Value) -> StreamMutation, applying strategy: ExecutionStrategy) -> (StreamState) -> StreamMutation {
        let feedbackFromEffectStream: (StreamState) -> StreamMutation = { states in
            return states.flatMap(effect)
        }

        return feedbackFromEffectStream
    }
}
