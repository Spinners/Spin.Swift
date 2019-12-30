//
//  AnySpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// `AnySpin` is a concrete implemtation of `Spin`. This is what is to be returned in a concrete SpinDefinition implementation or a `Spinner` building process
public struct AnySpin<StreamState: ReactiveStream>: Spin {
    public let stream: StreamState

    public init<StreamMutation, ReducerType: Reducer>(initialState: StreamState.Value, feedbackStream: @escaping (StreamState) -> StreamMutation, reducer: ReducerType)
        where   StreamMutation == ReducerType.StreamMutation,
                ReducerType.StreamState == StreamState {
        self.stream = reducer.reduce(initialState: initialState, feedback: feedbackStream)
    }

    public init<StreamMutation, ReducerType: Reducer>(initialState: StreamState.Value, feedbackStreams: [(StreamState) -> StreamMutation], reducer: ReducerType)
        where   StreamMutation == ReducerType.StreamMutation,
                ReducerType.StreamState == StreamState {
        self.stream = reducer.reduce(initialState: initialState, feedbacks: feedbackStreams)
    }

    public init<FeedbackType: Feedback, ReducerType: Reducer>(initialState: StreamState.Value, feedback: FeedbackType, reducer: ReducerType) where  FeedbackType.StreamState == StreamState,
                                                                                                                                                    FeedbackType.StreamState.Value == StreamState.Value,
                                                                                                                                                    FeedbackType.StreamState == ReducerType.StreamState,
                                                                                                                                                    FeedbackType.StreamMutation == ReducerType.StreamMutation {
        self.stream = reducer.reduce(initialState: initialState, feedback: feedback.feedbackStream)
    }

    public init<FeedbackType: Feedback, ReducerType: Reducer>(initialState: StreamState.Value,
                reducer: ReducerType,
                @FeedbackBuilder feedbackBuilder: () -> FeedbackType)
        where   FeedbackType.StreamState == ReducerType.StreamState,
                FeedbackType.StreamMutation == ReducerType.StreamMutation,
                FeedbackType.StreamState == StreamState {
        self.init(initialState: initialState, feedback: feedbackBuilder(), reducer: reducer)
    }

    public init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, ReducerType: Reducer>(initialState: StreamState.Value,
                                                                  reducer: ReducerType,
                                                                  @FeedbackBuilder builder: () -> (FeedbackTypeA, FeedbackTypeB))
        where   FeedbackTypeA.StreamState == ReducerType.StreamState,
                FeedbackTypeA.StreamMutation == ReducerType.StreamMutation,
                FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackTypeA(feedbacks: feedbacks.0, feedbacks.1)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, ReducerType: Reducer>(initialState: StreamState.Value,
                                                                                           reducer: ReducerType,
                                                                                           @FeedbackBuilder builder: () -> (FeedbackTypeA, FeedbackTypeB,  FeedbackTypeC))
        where   FeedbackTypeA.StreamState == ReducerType.StreamState,
                FeedbackTypeA.StreamMutation == ReducerType.StreamMutation,
                FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackTypeA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, ReducerType: Reducer>(initialState: StreamState.Value,
                                                                                                                    reducer: ReducerType,
                                                                                                                    @FeedbackBuilder builder: () -> (   FeedbackTypeA,
                                                                                                                                                        FeedbackTypeB,
                                                                                                                                                        FeedbackTypeC,
                                                                                                                                                        FeedbackTypeD))
        where   FeedbackTypeA.StreamState == ReducerType.StreamState,
                FeedbackTypeA.StreamMutation == ReducerType.StreamMutation,
                FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                FeedbackTypeA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackTypeA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2, feedbacks.3)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }

    public init<FeedbackTypeA: Feedback, FeedbackTypeB: Feedback, FeedbackTypeC: Feedback, FeedbackTypeD: Feedback, FeedbackTypeE: Feedback, ReducerType: Reducer>(initialState: StreamState.Value,
                                                                                                                                                                   reducer: ReducerType,
                                                                                                                                             @FeedbackBuilder builder: () -> (  FeedbackTypeA,
                                                                                                                                                                                FeedbackTypeB,
                                                                                                                                                                                FeedbackTypeC,
                                                                                                                                                                                FeedbackTypeD,
                                                                                                                                                                                FeedbackTypeE))
        where   FeedbackTypeA.StreamState == ReducerType.StreamState,
                FeedbackTypeA.StreamMutation == ReducerType.StreamMutation,
                FeedbackTypeA.StreamState == FeedbackTypeB.StreamState,
                FeedbackTypeA.StreamMutation == FeedbackTypeB.StreamMutation,
                FeedbackTypeB.StreamState == FeedbackTypeC.StreamState,
                FeedbackTypeB.StreamMutation == FeedbackTypeC.StreamMutation,
                FeedbackTypeC.StreamState == FeedbackTypeD.StreamState,
                FeedbackTypeC.StreamMutation == FeedbackTypeD.StreamMutation,
                FeedbackTypeD.StreamState == FeedbackTypeE.StreamState,
                FeedbackTypeD.StreamMutation == FeedbackTypeE.StreamMutation,
                FeedbackTypeA.StreamState == StreamState {
            let feedbacks = builder()
            let feedback = FeedbackTypeA(feedbacks: feedbacks.0, feedbacks.1, feedbacks.2, feedbacks.3, feedbacks.4)
            self.init(initialState: initialState, feedback: feedback, reducer: reducer)
    }
}
