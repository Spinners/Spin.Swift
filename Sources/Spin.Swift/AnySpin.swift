//
//  AnySpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// `AnySpin` is a concrete implementation of `Spin`. This is what is to be returned in a concrete SpinDefinition
/// implementation or a `Spinner` building process
public struct AnySpin<StreamState: ReactiveStream>: Spin {
    public let stream: StreamState

    public init<StreamEvent, ReducerType>(initialState: StreamState.Value,
                                          feedbackStream: @escaping (StreamState) -> StreamEvent,
                                          reducer: ReducerType)
        where
        ReducerType: Reducer,
        StreamEvent == ReducerType.StreamEvent,
        ReducerType.StreamState == StreamState {
            self.stream = reducer.apply(on: initialState, after: feedbackStream)
    }

    public init<StreamEvent, ReducerType>(initialState: StreamState.Value,
                                          feedbackStreams: [(StreamState) -> StreamEvent], reducer: ReducerType)
        where
        ReducerType: Reducer,
        StreamEvent == ReducerType.StreamEvent,
        ReducerType.StreamState == StreamState {
            self.stream = reducer.apply(on: initialState, after: feedbackStreams)
    }

    public init<FeedbackType, ReducerType>(initialState: StreamState.Value,
                                           feedback: FeedbackType,
                                           reducer: ReducerType)
        where
        FeedbackType: Feedback,
        ReducerType: Reducer,
        FeedbackType.StreamState == StreamState,
        FeedbackType.StreamState.Value == StreamState.Value,
        FeedbackType.StreamState == ReducerType.StreamState,
        FeedbackType.StreamEvent == ReducerType.StreamEvent {
            self.stream = reducer.apply(on: initialState, after: feedback.feedbackStream)
    }

    public init<FeedbackType, ReducerType>(initialState: StreamState.Value,
                                           reducer: ReducerType,
                                           @FeedbackBuilder feedbackBuilder: () -> FeedbackType)
        where
        FeedbackType: Feedback, ReducerType: Reducer,
        FeedbackType.StreamState == ReducerType.StreamState,
        FeedbackType.StreamEvent == ReducerType.StreamEvent,
        FeedbackType.StreamState == StreamState {
            self.init(initialState: initialState, feedback: feedbackBuilder(), reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, ReducerType>(initialState: StreamState.Value,
                                                   reducer: ReducerType,
                                                   @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        ReducerType: Reducer,
        FeedbackA.StreamState == ReducerType.StreamState,
        FeedbackA.StreamEvent == ReducerType.StreamEvent,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, ReducerType>(initialState: StreamState.Value,
                                                              reducer: ReducerType,
                                                              @FeedbackBuilder builder: () -> ( FeedbackA,
                                                                                                FeedbackB,
                                                                                                FeedbackC))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        ReducerType: Reducer,
        FeedbackA.StreamState == ReducerType.StreamState,
        FeedbackA.StreamEvent == ReducerType.StreamEvent,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, ReducerType>(initialState: StreamState.Value,
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
        FeedbackA.StreamState == ReducerType.StreamState,
        FeedbackA.StreamEvent == ReducerType.StreamEvent,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2, feedbacks.3)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, ReducerType>(initialState: StreamState.Value,
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
        FeedbackA.StreamState == ReducerType.StreamState,
        FeedbackA.StreamEvent == ReducerType.StreamEvent,
        FeedbackA.StreamState == FeedbackB.StreamState,
        FeedbackA.StreamEvent == FeedbackB.StreamEvent,
        FeedbackB.StreamState == FeedbackC.StreamState,
        FeedbackB.StreamEvent == FeedbackC.StreamEvent,
        FeedbackC.StreamState == FeedbackD.StreamState,
        FeedbackC.StreamEvent == FeedbackD.StreamEvent,
        FeedbackD.StreamState == FeedbackE.StreamState,
        FeedbackD.StreamEvent == FeedbackE.StreamEvent,
        FeedbackA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2, feedbacks.3, feedbacks.4)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }
}
