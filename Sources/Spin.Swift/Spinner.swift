//
//  Spinner.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

public class Spinner<State> {
    internal let initialState: State
    
    internal init (initialState state: State) {
        self.initialState = state
    }
    
    public static func initialState(_ state: State) -> Spinner<State> {
        return Spinner<State>(initialState: state)
    }
    
    public func feedback<FeedbackType: FeedbackDefinition>(_ feedback: FeedbackType) -> SpinnerFeedback< FeedbackType.StateStream,
        FeedbackType.EventStream>
        where FeedbackType.StateStream.Value == State {
            return SpinnerFeedback< FeedbackType.StateStream, FeedbackType.EventStream>(initialState: self.initialState,
                                                                                        feedbacks: [feedback])
    }
}

public class SpinnerFeedback<StateStream: ReactiveStream, EventStream: ReactiveStream> {
    internal let initialState: StateStream.Value
    internal var effects: [(StateStream) -> EventStream]
    
    internal init<FeedbackType: FeedbackDefinition> (initialState state: StateStream.Value,
                                           feedbacks: [FeedbackType])
        where
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            self.initialState = state
            self.effects = feedbacks.map { $0.effect }
    }
    
    public func feedback<NewFeedbackType>(_ feedback: NewFeedbackType) -> SpinnerFeedback<StateStream, EventStream>
        where
        NewFeedbackType: FeedbackDefinition,
        NewFeedbackType.StateStream == StateStream,
        NewFeedbackType.EventStream == EventStream {
            self.effects.append(feedback.effect)
            return self
    }
    
    public func reducer<ReducerType>(_ reducer: ReducerType) -> AnySpin<StateStream, EventStream>
        where
        ReducerType: ReducerDefinition,
        ReducerType.StateStream == StateStream,
        ReducerType.EventStream == EventStream {
            return AnySpin<StateStream, EventStream>(initialState: self.initialState,
                                                     effects: self.effects,
                                                     scheduledReducer: reducer.scheduledReducer(with: initialState))
    }
}
