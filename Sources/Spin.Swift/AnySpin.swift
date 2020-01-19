//
//  AnySpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// `AnySpin` is a concrete implementation of `Spin`. This is what is to be returned in a concrete SpinDefinition
/// implementation or a `Spinner` building process
public struct AnySpin<StateStream: ReactiveStream>: Spin {
    public let stream: StateStream

    public init<EventStream, ReducerType>(initialState: StateStream.Value,
                                          feedbackStream: @escaping (StateStream) -> EventStream,
                                          reducer: ReducerType)
        where
        ReducerType: Reducer,
        EventStream == ReducerType.EventStream,
        ReducerType.StateStream == StateStream {
            self.stream = reducer.apply(on: initialState, after: feedbackStream)
    }

    public init<EventStream, ReducerType>(initialState: StateStream.Value,
                                          feedbackStreams: [(StateStream) -> EventStream], reducer: ReducerType)
        where
        ReducerType: Reducer,
        EventStream == ReducerType.EventStream,
        ReducerType.StateStream == StateStream {
            self.stream = reducer.apply(on: initialState, after: feedbackStreams)
    }

    public init<FeedbackType, ReducerType>(initialState: StateStream.Value,
                                           feedback: FeedbackType,
                                           reducer: ReducerType)
        where
        FeedbackType: Feedback,
        ReducerType: Reducer,
        FeedbackType.StateStream == StateStream,
        FeedbackType.StateStream.Value == StateStream.Value,
        FeedbackType.StateStream == ReducerType.StateStream,
        FeedbackType.EventStream == ReducerType.EventStream {
            self.stream = reducer.apply(on: initialState, after: feedback.feedbackStream)
    }

    public init<FeedbackType, ReducerType>(initialState: StateStream.Value,
                                           reducer: ReducerType,
                                           @FeedbackBuilder feedbackBuilder: () -> FeedbackType)
        where
        FeedbackType: Feedback, ReducerType: Reducer,
        FeedbackType.StateStream == ReducerType.StateStream,
        FeedbackType.EventStream == ReducerType.EventStream,
        FeedbackType.StateStream == StateStream {
            self.init(initialState: initialState, feedback: feedbackBuilder(), reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, ReducerType>(initialState: StateStream.Value,
                                                   reducer: ReducerType,
                                                   @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        ReducerType: Reducer,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, ReducerType>(initialState: StateStream.Value,
                                                              reducer: ReducerType,
                                                              @FeedbackBuilder builder: () -> ( FeedbackA,
                                                                                                FeedbackB,
                                                                                                FeedbackC))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        ReducerType: Reducer,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, ReducerType>(initialState: StateStream.Value,
                                                                         reducer: ReducerType,
                                                                         @FeedbackBuilder builder: () -> (  FeedbackA,
                                                                                                            FeedbackB,
                                                                                                            FeedbackC,
                                                                                                            FeedbackD))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        ReducerType: Reducer,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2, feedbacks.3)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, ReducerType>(initialState: StateStream.Value,
                                                                                    reducer: ReducerType,
                                                                                    @FeedbackBuilder builder: () -> (   FeedbackA,
                                                                                                                        FeedbackB,
                                                                                                                        FeedbackC,
                                                                                                                        FeedbackD,
                                                                                                                        FeedbackE))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackE: Feedback,
        ReducerType: Reducer,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream,
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2, feedbacks.3, feedbacks.4)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }
}
