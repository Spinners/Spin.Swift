//
//  Spinner.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

import Foundation

public class AnySpinner<State, Executer: ExecuterDefinition> {
    let initialState: State
    let executer: Executer.Executer
    
    init (initialState state: State, executer: Executer.Executer) {
        self.initialState = state
        self.executer = executer
    }
    
    public static func initialState(_ state: State, executeOn executer: Executer.Executer = Executer.defaultSpinExecuter()) -> AnySpinner<State, Executer> {
        return AnySpinner<State, Executer>(initialState: state, executer: executer)
    }
    
    public func feedback<Feedback>(_ feedback: Feedback) -> SpinnerFeedback<Feedback.StateStream, Feedback.EventStream, Executer>
        where
        Feedback: FeedbackDefinition,
        Feedback.StateStream.Value == State {
            return SpinnerFeedback<Feedback.StateStream, Feedback.EventStream, Executer>(initialState: self.initialState,
                                                                                         feedbacks: [feedback],
                                                                                         executer: self.executer)
    }
}

public class SpinnerFeedback<StateStream: ReactiveStream, EventStream: ReactiveStream, Executer: ExecuterDefinition> {
    let initialState: StateStream.Value
    var effects: [(StateStream) -> EventStream]
    let executer: Executer.Executer
    
    init<Feedback: FeedbackDefinition> (initialState state: StateStream.Value,
                                        feedbacks: [Feedback],
                                        executer: Executer.Executer)
        where
        Feedback.StateStream == StateStream,
        Feedback.EventStream == EventStream {
            self.initialState = state
            self.effects = feedbacks.map { $0.effect }
            self.executer = executer
    }
    
    public func feedback<Feedback>(_ feedback: Feedback) -> SpinnerFeedback<StateStream, EventStream, Executer>
        where
        Feedback: FeedbackDefinition,
        Feedback.StateStream == StateStream,
        Feedback.EventStream == EventStream {
            self.effects.append(feedback.effect)
            return self
    }
    
    public func reducer(_ reducer: Reducer<StateStream.Value, EventStream.Value>) -> AnySpin<StateStream, EventStream, Executer> {
            return AnySpin<StateStream, EventStream, Executer>(initialState: self.initialState,
                                                               effects: self.effects,
                                                               reducer: reducer.reducer,
                                                               executer: self.executer)
    }
}
