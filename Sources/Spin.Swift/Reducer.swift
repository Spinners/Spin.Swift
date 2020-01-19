//
//  Reducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A Reducer represents the way a reactive stream of `Event` can
/// sequentially mutate an initial `State` over time be executing a sequence of `Feedbacks`
public protocol Reducer {
    associatedtype StreamState: ReactiveStream
    associatedtype StreamEvent: ReactiveStream
    associatedtype Executer

    var reducer: (StreamState.Value, StreamEvent.Value) -> StreamState.Value { get }
    var executer: Executer { get }

    init(reducer: @escaping (StreamState.Value, StreamEvent.Value) -> StreamState.Value, on executer: Executer)

    func reduce(initialState: StreamState.Value,
                feedback: @escaping (StreamState) -> StreamEvent) -> StreamState

    func reduce(initialState: StreamState.Value,
                feedbacks: [(StreamState) -> StreamEvent]) -> StreamState
}

public extension Reducer {
    /// Set an executer for the reducer after its initilization
    /// - Parameter executer: the executer on which the reducer will be executed
    func execute(on executer: Executer) -> Self {
        let newReducer = Self(reducer: self.reducer, on: executer)
        return newReducer
    }
}
