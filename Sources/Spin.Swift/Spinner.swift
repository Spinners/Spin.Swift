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

    public func add<FeedbackType: Feedback>(feedback: FeedbackType) -> SpinnerFeedback< FeedbackType.StateStream,
                                                                                        FeedbackType.EventStream>
        where FeedbackType.StateStream.Value == State {
            return SpinnerFeedback< FeedbackType.StateStream, FeedbackType.EventStream>(initialState: self.initialState,
                                                                                        feedback: feedback)
    }
}

public struct SpinnerFeedback<StateStream: ReactiveStream, EventStream: ReactiveStream> {
    internal let initialState: StateStream.Value
    internal let feedbackStreams: [(StateStream) -> EventStream]

    internal init (initialState state: StateStream.Value, feedbackStreams: [(StateStream) -> EventStream]) {
        self.initialState = state
        self.feedbackStreams = feedbackStreams
    }

    internal init<FeedbackType: Feedback> (initialState state: StateStream.Value,
                                           feedback: FeedbackType)
        where
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            self.init(initialState: state, feedbackStreams: [feedback.feedbackStream])
    }

    public func add<NewFeedbackType>(feedback: NewFeedbackType) -> SpinnerFeedback<StateStream, EventStream>
        where
        NewFeedbackType: Feedback,
        NewFeedbackType.StateStream == StateStream,
        NewFeedbackType.EventStream == EventStream {
            let newFeedbackStreams = self.feedbackStreams + [feedback.feedbackStream]
            return SpinnerFeedback<StateStream, EventStream>(initialState: self.initialState,
                                                             feedbackStreams: newFeedbackStreams)
    }

    public func reduce<ReducerType>(with reducer: ReducerType) -> AnySpin<StateStream>
        where
        ReducerType: Reducer,
        ReducerType.StateStream == StateStream,
        ReducerType.EventStream == EventStream {
            return AnySpin<StateStream>(initialState: self.initialState,
                                        feedbackStreams: self.feedbackStreams,
                                        reducer: reducer)
    }
}
