//
//  Reducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A Reducer represents the way a reactive stream of `Event` can
/// sequentially mutate an initial `State` over time be executing a sequence of `Feedbacks`
public protocol Reducer {
    associatedtype StateStream: ReactiveStream
    associatedtype EventStream: ReactiveStream
    associatedtype Executer

    var reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value { get }
    var executer: Executer { get }

    init(_ reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value, on executer: Executer)
    func scheduledReducer(with initialState: StateStream.Value) -> (EventStream) -> StateStream
}
