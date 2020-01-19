//
//  Spinner.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

public struct Spinner<State> {
    internal let initialState: State

    internal init (initialState state: State) {
        self.initialState = state
    }

    public static func from(initialState state: State) -> Spinner<State> {
        return Spinner<State>(initialState: state)
    }

    public func add<FeedbackType: Feedback>(feedback: FeedbackType) -> SpinnerFeedback< FeedbackType.StreamState,
                                                                                        FeedbackType.StreamEvent>
        where FeedbackType.StreamState.Value == State {
            return SpinnerFeedback< FeedbackType.StreamState, FeedbackType.StreamEvent>(initialState: self.initialState,
                                                                                        feedback: feedback)
    }
}

public struct SpinnerFeedback<StreamState: ReactiveStream, StreamEvent: ReactiveStream> {
    internal let initialState: StreamState.Value
    internal let feedbackStreams: [(StreamState) -> StreamEvent]

    internal init (initialState state: StreamState.Value, feedbackStreams: [(StreamState) -> StreamEvent]) {
        self.initialState = state
        self.feedbackStreams = feedbackStreams
    }

    internal init<FeedbackType: Feedback> (initialState state: StreamState.Value,
                                           feedback: FeedbackType)
        where
        FeedbackType.StreamState == StreamState,
        FeedbackType.StreamEvent == StreamEvent {
            self.init(initialState: state, feedbackStreams: [feedback.feedbackStream])
    }

    public func add<NewFeedbackType>(feedback: NewFeedbackType) -> SpinnerFeedback<StreamState, StreamEvent>
        where
        NewFeedbackType: Feedback,
        NewFeedbackType.StreamState == StreamState,
        NewFeedbackType.StreamEvent == StreamEvent {
            let newFeedbackStreams = self.feedbackStreams + [feedback.feedbackStream]
            return SpinnerFeedback<StreamState, StreamEvent>(initialState: self.initialState,
                                                             feedbackStreams: newFeedbackStreams)
    }

    public func reduce<ReducerType>(with reducer: ReducerType) -> AnySpin<StreamState>
        where
        ReducerType: Reducer,
        ReducerType.StreamState == StreamState,
        ReducerType.StreamEvent == StreamEvent {
            return AnySpin<StreamState>(initialState: self.initialState,
                                        feedbackStreams: self.feedbackStreams,
                                        reducer: reducer)
    }
}
