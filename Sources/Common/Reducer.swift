//
//  Reducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A Reducer represents the way a reactive stream of `Event` can
/// sequentially mutate an initial `State` over time be executing a sequence of `Feedbacks`

public struct Reducer<State, Event> {
    public let reducer: (State, Event) -> State

    public init(_ reducer: @escaping (State, Event) -> State) {
        self.reducer = reducer
    }
}
