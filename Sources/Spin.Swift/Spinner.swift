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
        FeedbackType.StreamMutation>
        where FeedbackType.StreamState.Value == State {
            return SpinnerFeedback< FeedbackType.StreamState, FeedbackType.StreamMutation>(initialState: self.initialState,
                                                                                           feedback: feedback)
    }
}

public struct SpinnerFeedback<StreamState: ReactiveStream, StreamMutation: ReactiveStream> {
    internal let initialState: StreamState.Value
    internal let feedbackStreams: [(StreamState) -> StreamMutation]

    internal init (initialState state: StreamState.Value, feedbackStreams: [(StreamState) -> StreamMutation]) {
        self.initialState = state
        self.feedbackStreams = feedbackStreams
    }

    internal init<FeedbackType: Feedback> (initialState state: StreamState.Value,
                                           feedback: FeedbackType)
        where
        FeedbackType.StreamState == StreamState,
        FeedbackType.StreamMutation == StreamMutation {
            self.init(initialState: state, feedbackStreams: [feedback.feedbackStream])
    }

    public func add<NewFeedbackType>(feedback: NewFeedbackType) -> SpinnerFeedback<StreamState, StreamMutation>
        where
        NewFeedbackType: Feedback,
        NewFeedbackType.StreamState == StreamState,
        NewFeedbackType.StreamMutation == StreamMutation {
            let newFeedbackStreams = self.feedbackStreams + [feedback.feedbackStream]
            return SpinnerFeedback<StreamState, StreamMutation>(initialState: self.initialState,
                                                                feedbackStreams: newFeedbackStreams)
    }

    public func reduce<ReducerType>(with reducer: ReducerType) -> AnySpin<StreamState>
        where
        ReducerType: Reducer,
        ReducerType.StreamState == StreamState,
        ReducerType.StreamMutation == StreamMutation {
            return AnySpin<StreamState>(initialState: self.initialState,
                                        feedbackStreams: self.feedbackStreams, reducer: reducer)
    }
}
