//
//  Reducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxRelay
import RxSwift
import SpinCommon

public typealias RxReducer = SpinRxSwift.Reducer

public struct Reducer<State, Event>: ReducerDefinition {
    public typealias StateStream = Observable<State>
    public typealias EventStream = Observable<Event>
    public typealias Executer = ImmediateSchedulerType

    public let reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value
    public let executer: Executer
    
    public init(_ reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value,
                on executer: Executer = CurrentThreadScheduler.instance) {
        self.reducer = reducer
        self.executer = executer
    }

    public func scheduledReducer(with initialState: StateStream.Value) -> (EventStream) -> StateStream {
        return { events in
            events
                .observeOn(self.executer)
                .scan(initialState, accumulator: self.reducer)
        }
    }
}
